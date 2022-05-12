from RPA.Robocorp.Vault import Vault

secret_url = Vault().get_secret("url")
SECRET_ROBOT_ORDERS_WEB_URL = secret_url["robot_order_web_site"]
