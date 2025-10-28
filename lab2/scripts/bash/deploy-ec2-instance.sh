#!/usr/bin/env bash
set -Eeuo pipefail

# --------- Paramètres ----------
REGION="${REGION:-eu-north-1}"
SG_NAME="${SG_NAME:-sample-app}"
INSTANCE_TYPE="${INSTANCE_TYPE:-t3.micro}"  # Free Tier souvent OK
APP_PORT="${APP_PORT:-80}"                  # adapte si ton app écoute 8080
USER_DATA_FILE="user-data.sh"

# --------- Trouver l'AMI Amazon Linux 2 de la région ----------
AMI_ID=$(aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --region "$REGION" \
  --query "Images | sort_by(@, &CreationDate)[-1].ImageId" \
  --output text)

echo "Region: $REGION"
echo "AMI:    $AMI_ID"

# --------- Récupérer ou créer le Security Group ----------
# (dans le VPC par défaut)
VPC_ID=$(aws ec2 describe-vpcs \
  --filters "Name=isDefault,Values=true" \
  --region "$REGION" \
  --query "Vpcs[0].VpcId" \
  --output text)

SG_ID=$(aws ec2 describe-security-groups \
  --region "$REGION" \
  --filters "Name=vpc-id,Values=$VPC_ID" "Name=group-name,Values=$SG_NAME" \
  --query "SecurityGroups[0].GroupId" \
  --output text 2>/dev/null || true)

if [ -z "$SG_ID" ] || [ "$SG_ID" = "None" ]; then
  echo "Security group inexistant, création..."
  SG_ID=$(aws ec2 create-security-group \
    --group-name "$SG_NAME" \
    --description "Allow HTTP(${APP_PORT}) and SSH(22)" \
    --vpc-id "$VPC_ID" \
    --region "$REGION" \
    --query "GroupId" \
    --output text)
  echo "SG créé: $SG_ID"
else
  echo "SG existant: $SG_ID"
fi

# Autoriser les règles si absentes (idempotent)
need22=$(aws ec2 describe-security-groups \
  --group-id "$SG_ID" --region "$REGION" \
  --query "length(SecurityGroups[0].IpPermissions[?FromPort==\`22\` && ToPort==\`22\` && IpProtocol=='tcp'])" \
  --output text)

if [ "$need22" = "0" ]; then
  aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" --protocol tcp --port 22 --cidr 0.0.0.0/0 --region "$REGION"
fi

needapp=$(aws ec2 describe-security-groups \
  --group-id "$SG_ID" --region "$REGION" \
  --query "length(SecurityGroups[0].IpPermissions[?FromPort==\`$APP_PORT\` && ToPort==\`$APP_PORT\` && IpProtocol=='tcp'])" \
  --output text)

if [ "$needapp" = "0" ]; then
  aws ec2 authorize-security-group-ingress \
    --group-id "$SG_ID" --protocol tcp --port "$APP_PORT" --cidr 0.0.0.0/0 --region "$REGION"
fi

# --------- Lancer l'instance ----------
if [ ! -f "$USER_DATA_FILE" ]; then
  echo "Le fichier $USER_DATA_FILE est introuvable dans le répertoire courant."
  exit 1
fi

INSTANCE_ID=$(aws ec2 run-instances \
  --image-id "$AMI_ID" \
  --instance-type "$INSTANCE_TYPE" \
  --region "$REGION" \
  --security-group-ids "$SG_ID" \
  --user-data "file://$USER_DATA_FILE" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${SG_NAME}}]" \
  --query "Instances[0].InstanceId" \
  --output text)

echo "Instance créée: $INSTANCE_ID"

# --------- Attendre l'état running ----------
aws ec2 wait instance-running --instance-ids "$INSTANCE_ID" --region "$REGION"

# --------- Récupérer l'IP publique ----------
PUBLIC_IP=$(aws ec2 describe-instances \
  --instance-ids "$INSTANCE_ID" \
  --region "$REGION" \
  --query "Reservations[0].Instances[0].PublicIpAddress" \
  --output text)

echo "-------------------------------------"
echo "Instance ID       = $INSTANCE_ID"
echo "Security Group ID = $SG_ID"
echo "Public IP         = $PUBLIC_IP"
echo "Test: http://$PUBLIC_IP:${APP_PORT}"