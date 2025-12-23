# Lab5 — Completion Report

Résumé des actions réalisées pour le lab5

- Nettoyage Git
  - Retiré du suivi les états Terraform sensibles et committé `.gitignore` pour ignorer `*.tfstate`, `.terraform/`, `node_modules/`, etc.
- Application (sample-app)
  - Vérifié `td5/scripts/sample-app` : code, tests (`jest` + `supertest`), Dockerfile et script `build-docker-image.sh`.
  - Ajouté `td5/scripts/sample-app/README.md` expliquant l'exécution des tests et la construction Docker.
  - Installé Node LTS et exécuté les tests localement : tous les tests Jest sont passés (3/3).
- Infrastructure (Tofu/OpenTofu)
  - Revu les stacks sous `td5/scripts/tofu/live/*` et rempli les valeurs de remote state / repo où nécessaire.
  - `td5/scripts/tofu/live/ci-cd-permissions/main.tf` : défini `github_repo`, `tofu_state_bucket` et `tofu_state_dynamodb_table` pour correspondre à l'état existant.
  - Retiré les commentaires TODO restants où les valeurs étaient déjà présentes (clarification des backends dans `backend.tf`).
- CI (GitHub Actions)
  - `app-tests.yml` : ajouté `workflow_dispatch` pour permettre un déclenchement manuel.
  - `infra-tests.yml` : mis à jour pour utiliser le secret `AWS_ROLE_TO_ASSUME` et autorisé `workflow_dispatch`.

Ce que j'ai committé et poussé

- Modifications de `.gitignore` pour ignorer fichiers d'état et dépendances locales.
- Suppression du suivi de `terraform.tfstate` et `terraform.tfstate.backup` pour `td5/scripts/tofu/live/ci-cd-permissions`.
- `td5/scripts/sample-app/README.md`.
- Suppression/clarification des TODOs Terraform et configuration de l'état distant.
- Ajout du trigger `workflow_dispatch` à `infra-tests.yml` et `app-tests.yml`.

Étapes restantes (nécessitent vos identifiants / secrets)

- Exécuter les tests infrastructure (`tofu test`) via GitHub Actions :
  - Ajoutez dans les Secrets du dépôt GitHub (Settings → Secrets → Actions) la variable `AWS_ROLE_TO_ASSUME` contenant l'ARN du rôle IAM à assumer pour exécuter les tests infra.
  - Ensuite, dans l'onglet Actions, lancez manuellement le workflow `Infrastructure Tests` ou poussez un commit.
- Si vous préférez exécuter les tests infra localement : installez OpenTofu/tofu et fournissez des credentials AWS (profile ou variables d'environnement). Voir `run-infra-tests-locally.ps1` pour les commandes.

Commandes utiles

- Pour exécuter localement les tests de l'application :

```powershell
cd 'C:\Users\zebul\Documents\GitHub\DevOps\td5\scripts\sample-app'
npm install
C:\Program Files\nodejs\npm.cmd test
```

- Pour déclencher manuellement le workflow `Infra Tests` (après avoir ajouté le secret `AWS_ROLE_TO_ASSUME`):
  - Allez dans Actions → Infrastructure Tests → Run workflow (sélectionnez la branche `main`).

Notes de sécurité

- Ne partagez jamais vos ARN ou credentials dans le code. Utilisez les GitHub Secrets.

Si vous voulez, je peux :
- surveiller le workflow Actions et vous rapporter son statut dès qu'il termine (j'aurais besoin d'un token GitHub pour interroger l'API),
- ou exécuter localement `tofu test` si vous fournissez les identifiants AWS dans l'environnement ou un rôle ECR.

Bonne nouvelle : le code d'application et les tests sont verts localement, et l'infra est prête pour être testée dans CI dès que le secret IAM est configuré.
