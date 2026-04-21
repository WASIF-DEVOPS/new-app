import json
import os

import boto3


def _load_db_config():
    secret_name = os.getenv("DB_SECRET_NAME", "dev/three-tier-app/db")
    region = os.getenv("AWS_REGION", os.getenv("AWS_DEFAULT_REGION", "us-east-1"))

    client = boto3.client("secretsmanager", region_name=region)
    secret_response = client.get_secret_value(SecretId=secret_name)
    secret_payload = secret_response.get("SecretString")
    if not secret_payload:
        raise ValueError(f"Secret {secret_name} has no SecretString payload")
    return json.loads(secret_payload)


_db_config = _load_db_config()

master_username = _db_config["DB_USER"]
db_password = _db_config["DB_PASSWORD"]
endpoint = _db_config["DB_HOST"]
db_instance_name = _db_config["DB_NAME"]

if __name__ == "__main__":
    print(master_username, db_password, endpoint, db_instance_name)
