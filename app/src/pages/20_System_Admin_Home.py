import logging
logger = logging.getLogger(__name__)

import streamlit as st
from modules.nav import SideBarLinks

st.set_page_config(layout='wide')
SideBarLinks()

st.title("Rigby's System Admin Dashboard")
st.write("### What would you like to do today?")

col1, col2, col3 = st.columns(3)

with col1:
    if st.button('System Logs', type='primary', use_container_width=True):
        st.switch_page('pages/22_System_Logs.py')

with col2:
    if st.button('Help Requests', type='primary', use_container_width=True):
        st.switch_page('pages/23_Help_Requests.py')

with col3:
    if st.button('Platform Monitor', type='primary', use_container_width=True):
        st.switch_page('pages/24_Platform_Monitor.py')
