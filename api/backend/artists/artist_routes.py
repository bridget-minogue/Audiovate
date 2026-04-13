from flask import Blueprint, jsonify, request, current_app
from backend.db_connection import get_db
from mysql.connector import Error

# Create a Blueprint for Artist routes
artists = Blueprint("artists", __name__)

@artists.route("/artists/<int:artist_id>", methods=["GET"])
def get_artist(artist_id):
    cursor = get_db().cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM artist WHERE artist_id = %s", (artist_id,))
        artist = cursor.fetchone()

        if not artist:
            return jsonify({"error": "artist not found"}), 404

        # Reuse the same cursor for the follow-up queries
        cursor.execute("SELECT * FROM release WHERE artist_id = %s", (artist_id,))
        artist["releases"] = cursor.fetchall()

        return jsonify(artist), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()