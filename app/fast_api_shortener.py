from flask import Flask, request, redirect, render_template, jsonify
import sqlite3
import string
import random
import os

app = Flask(__name__)
DB_FILE = 'urls.db'

# ---------- DATABASE SETUP ----------
def init_db():
    with sqlite3.connect(DB_FILE) as conn:
        conn.execute('''
            CREATE TABLE IF NOT EXISTS urls (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                short_code TEXT UNIQUE NOT NULL,
                original_url TEXT NOT NULL
            )
        ''')

# ---------- HELPERS ----------
def generate_code(length=6):
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for _ in range(length))

def insert_url(original_url):
    code = generate_code()

    # ✅ Add protocol if missing
    if not original_url.startswith(('http://', 'https://')):
        original_url = 'http://' + original_url

    print(f"Storing URL: {original_url} with code: {code}")

    with sqlite3.connect(DB_FILE) as conn:
        try:
            conn.execute(
                'INSERT INTO urls (short_code, original_url) VALUES (?, ?)',
                (code, original_url)
            )
            return code
        except sqlite3.IntegrityError:
            return insert_url(original_url)

def get_original_url(code):
    with sqlite3.connect(DB_FILE) as conn:
        row = conn.execute(
            'SELECT original_url FROM urls WHERE short_code = ?',
            (code,)
        ).fetchone()
        return row[0] if row else None

# ---------- ROUTES ----------
@app.route('/')
def index():
    return render_template('index.html')

@app.route('/shorten', methods=['POST'])
def shorten():
    long_url = request.form.get('url')
    if not long_url:
        return render_template('index.html', error="No URL provided")

    short_code = insert_url(long_url)
    short_url = request.host_url + short_code
    return render_template('index.html', short_url=short_url)

@app.route('/<code>')
def redirect_to_original(code):
    original_url = get_original_url(code)
    if original_url:
        return redirect(original_url)
    return jsonify({'error': 'URL not found'}), 404

# ---------- RUN ----------
if __name__ == '__main__':
    if not os.path.exists(DB_FILE):
        init_db()
    app.run(host='0.0.0.0', port=5000, debug=True)
