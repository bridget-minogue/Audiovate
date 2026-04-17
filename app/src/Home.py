# Set up basic logging infrastructure
import logging
logging.basicConfig(format='%(filename)s:%(lineno)s:%(levelname)s -- %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks

import requests

st.set_page_config(layout='wide')
st.session_state['authenticated'] = False

SideBarLinks(show_home=True)

# ***************************************************
#    The major content of this page
# ***************************************************

logger.info("Loading the Home page of the app")
st.title('Audiovate')
st.write('#### Hi! As which user would you like to log in?')

def get_artists():
    try:
        response = requests.get("http://web-api:4000/artists")
        return response.json()
    except Exception as e:
        logger.error(f"Error fetching artists: {e}")
        return []

def get_all_users():
    try:
        response = requests.get("http://web-api:4000/users")
        return response.json()
    except Exception as e:
        logger.error(f"Error fetching users: {e}")
        return []

all_artists = get_artists()
all_users = get_all_users()

st.markdown("### Artist")
if all_artists:
    artist_map = {
    f"{a.get('first_name', 'Unknown')} {a.get('last_name', '')}": a
    for a in all_artists
}
    selected_name = st.selectbox("Choose an artist", options=list(artist_map.keys()), index=0)

    if st.button("Act as Artist", type="primary", use_container_width=True):
        # Find the matching record to get the ID
        user_data = next(a for a in all_artists if f"{a['first_name']} {a['last_name']}" == selected_name)
    
        st.session_state['authenticated'] = True
        st.session_state['role'] = 'artist'
        st.session_state['artist_id'] = user_data['artist_id']
        st.session_state['first_name'] = user_data['first_name']
        st.switch_page('pages/00_Artist_Home.py')
    else:
        st.warning("No artists found. Check if the database is seeded.")

st.divider()

st.markdown("### Manager")

managers = [u for u in all_users if u.get('role', '').lower() == 'manager']
if managers:
    manager_map = {f"{m['first_name']} {m['last_name']}": m for m in managers}
    selected_manager = st.selectbox("Choose a manager", options=list(manager_map.keys()), key="manager_select")

    if st.button("Act as Manager", type="primary", use_container_width=True):
        data = manager_map[selected_manager]
        st.session_state['authenticated'] = True
        st.session_state['role'] = 'manager'
        st.session_state['manager_id'] = data['user_id']
        st.session_state['first_name'] = data['first_name']
        st.session_state['last_name'] = data['last_name']
        st.switch_page('pages/10_Manager_Home.py')
else:
    st.info("No managers currently in system.")

st.divider()

st.markdown("### System Admin")
admins = [u for u in all_users if u.get('role', '').lower() == 'admin']
if admins:
    admin_map = {f"{a['first_name']} {a['last_name']}": a for a in admins}
    selected_admin = st.selectbox("Choose a system admin", options=list(admin_map.keys()), key="admin_select")

    if st.button("Act as Admin", type="primary", use_container_width=True):
        data = admin_map[selected_admin]
        st.session_state['authenticated'] = True
        st.session_state['role'] = 'admin'
        st.session_state['admin_id'] = data['user_id']
        st.session_state['first_name'] = data['first_name']
        st.session_state['last_name'] = data['last_name']
        st.switch_page('pages/20_Admin_Home.py')
