from flask import Flask, request, redirect, jsonify
import sqlite3
import string
import random
import os

app = Flask(__name__)
DATABASE = 'urls.db'

# --- DB Setup ---
def init_db():
    with sqlite3.connect(DATABASE) as conn:
        conn.execute('''
            CREATE TABLE IF NOT EXISTS urls (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                short TEXT UNIQUE,
                long TEXT NOT NULL
            )
        ''')

# --- Helper Functions ---
def generate_short_code(length=6):
    chars = string.ascii_letters + string.digits
    return ''.join(random.choice(chars) for _ in range(length))

def store_url(long_url):
    short = generate_short_code()
    print(short)
    with sqlite3.connect(DATABASE) as conn:
        try:
            conn.execute('INSERT INTO urls (short, long) VALUES (?, ?)', (short, long_url))
            return short
        except sqlite3.IntegrityError:
            return store_url(long_url)  # Retry if short code is not unique

def get_long_url(short):
    with sqlite3.connect(DATABASE) as conn:
        result = conn.execute('SELECT long FROM urls WHERE short = ?', (short,)).fetchone()
        return result[0] if result else None

# --- Routes ---
@app.route('/shorten', methods=['POST'])
def shorten():
    data = request.get_json()
    long_url = data.get('url')
    if not long_url:
        return jsonify({'error': 'No URL provided'}), 400

    short = store_url(long_url)
    return jsonify({'short_url': request.host_url + short})

@app.route('/<short>')
def redirect_to_url(short):
    long_url = get_long_url(short)
    if long_url:
        return redirect(long_url)
    return jsonify({'error': 'Short URL not found'}), 404

# --- Run App ---
if __name__ == '__main__':
    if not os.path.exists(DATABASE):
        init_db()
    app.run(debug=True)
