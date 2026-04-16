from requests import Response
from flask import Blueprint, jsonify, request, current_app
from backend.db_connection import get_db
from mysql.connector import Error


# Create a Blueprint for Artist routes
artists = Blueprint("artists", __name__)

@artists.route("/artists", methods=["GET"])
def get_artists():
    cursor = get_db().cursor(dictionary=True)
    try:
        cursor.execute("SELECT * FROM artist")
        artists = cursor.fetchall()
        return jsonify(artists), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

@artists.route("/artists/<int:artist_id>", methods=["GET"])
def get_artist(artist_id):
    cursor = get_db().cursor(dictionary=True)
    try:
        query = """
            SELECT
            a. *,
            u.first_name AS legal_first_name,
            u.last_name AS legal_last_name
            FROM artist a
            JOIN user u ON a.user_id = u.id
            WHERE a.artist_id = %s
        """
        cursor.execute(query, (artist_id,))
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

@artists.route("/artists/tax-status/<int:artist_id>", methods=["PUT"])
def update_tax_status(artist_id):
    cursor = get_db().cursor(dictionary=True)
    try:
        data = request.get_json()
        cursor.execute("SELECT artist_id FROM artist WHERE artist_id = %s", (artist_id,))
        if not cursor.fetchone():
            return jsonify({"error": "Artist not found"}), 404
        # Update status
        query = "UPDATE artist SET tax_id_status = %s WHERE artist_id = %s"
        cursor.execute(query, (data["tax_id_status"], artist_id))
        get_db().commit()
        return jsonify({"message": "Tax status updated successfully"}), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

@artists.route("/artists/<int:artist_id>", methods=["PUT"])
def update_artist_profile(artist_id):
    cursor = get_db().cursor(dictionary=True)
    try:
        data = request.get_json()
        cursor.execute("SELECT artist_id FROM artist WHERE artist_id = %s", (artist_id,))
        if not cursor.fetchone():
            return jsonify({"error": "Artist not found"}), 404
        # Build update query dynamically based on provided fields
        allowed_fields = ["bio", "instagram", "profile_pic"]
        update_fields = [f"{f} = %s" for f in allowed_fields if f in data]
        params = [data[f] for f in allowed_fields if f in data]

        if not update_fields:
            return jsonify({"error": "No valid fields to update"}), 400

        params.append(artist_id)
        query = f"UPDATE artist SET {', '.join(update_fields)} WHERE artist_id = %s"
        cursor.execute(query, params)
        get_db().commit()

        return jsonify({"message": "Artist profile updated successfully"}), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

@artists.route("/artists/<int:artist_id>/streaming-stats", methods=["GET"])
def get_monthly_stats(artist_id):
    cursor = get_db().cursor(dictionary=True)
    try:
        query = """
            SELECT
            t.title,
            MONTHNAME(s.timestamp) AS month,
            COUNT(s.event_id) AS total_streams
            FROM streamEvent s
            JOIN track t ON s.event_track_id = t.track_id
            WHERE t.track_artist_id = %s
            GROUP BY t.track_id, month
            ORDER BY s.timestamp DESC;
            """
        cursor.execute(query, (artist_id,))
        stats = cursor.fetchall()
        return jsonify(stats), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()

@artists.route("/artists/<int:artist_id>/platform-earnings", methods=["GET"])
def get_platform_earnings(artist_id):
    cursor = get_db().cursor(dictionary=True)
    try:
        query = """
            SELECT
            p.name AS platform_name,
            SUM(s.rev_generated) AS total_earnings
            FROM streamEvent s
            JOIN platform p ON s.event_platform_id = p.platform_id
            JOIN track t ON s.event_track_id = t.track_id
            WHERE t.track_artist_id = %s
            GROUP BY p.name;
        """
        cursor.execute(query, (artist_id,))
        earnings = cursor.fetchall()
        return jsonify(earnings), 200
    except Error as e:
        return jsonify({"error": str(e)}), 500
    finally:
        cursor.close()