Build the placeholder Lambda deployment package before running Terraform apply.

From the workspace root:

```bash
cd app/lambda
zip email_sender.zip lambda_function.py
```
