# "SQLite DB connection"=SQLite is a lightweight, serverless, self-contained, and embeddable SQL database engine.
import sqlite3

def get_db():
    conn = sqlite3.connect("users.db")
    conn.row_factory = sqlite3.Row
    return conn

# Create users table if not exists
def create_users_table():
    db = get_db()
    db.execute("""
        CREATE TABLE IF NOT EXISTS users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT UNIQUE,
            password TEXT
        )
    """)
    db.commit()

create_users_table()
