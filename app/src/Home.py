# Set up basic logging infrastructure
import logging
logging.basicConfig(format='%(filename)s:%(lineno)s:%(levelname)s -- %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks

from api.backend.audiovate_routes.artists.artist_routes import get_artists

st.set_page_config(layout='wide')
st.session_state['authenticated'] = False

SideBarLinks(show_home=True)

# ***************************************************
#    The major content of this page
# ***************************************************

logger.info("Loading the Home page of the app")
st.title('Audiovate')
st.write('#### Hi! As which user would you like to log in?')

all_artists = get_artists()

st.markdown("### Artist")
artist_map = {f"{a['first_name']} {a['last_name']}": a for a in all_artists}
    
selected_name = st.selectbox(
    "Choose an artist",
    options=list(artist_map.keys()),
    index=0,
)

if st.button("Act as Artist", type="primary", use_container_width=True):
    # Find the matching record to get the ID
    user_data = next(a for a in all_artists if f"{a['first_name']} {a['last_name']}" == selected_name)
    
    st.session_state['authenticated'] = True
    st.session_state['role'] = 'artist'
    st.session_state['artist_id'] = user_data['artist_id']
    st.session_state['first_name'] = user_data['first_name']
    st.switch_page('pages/00_Artist_Home.py')

st.divider()

st.markdown("### Manager")



