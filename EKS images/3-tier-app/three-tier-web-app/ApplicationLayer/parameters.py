import os

master_username = os.environ['DB_USER']
db_password = os.environ['DB_PASSWORD']
endpoint = os.environ['DB_HOST']
db_instance_name = os.environ['DB_NAME']

if __name__ == "__main__":
    print(master_username, db_password, endpoint, db_instance_name)
