# Idea borrowed from https://github.com/fsmosca/sample-streamlit-authenticator

# This file has functions to add links to the left sidebar based on the user's role.

import streamlit as st


# ---- General ----------------------------------------------------------------

def home_nav():
    st.sidebar.page_link("Home.py", label="Home", icon="🏠")


def about_page_nav():
    st.sidebar.page_link("pages/30_About.py", label="About", icon="🧠")


# ---- Role: artist ------------------------------------------------

def artist_home_nav():
    st.sidebar.page_link(
        "pages/00_Artist_Home.py", label="Artist Home", icon="👤"
    )


def artist_library_nav():
    st.sidebar.page_link(
        "pages/01_Artist_Library.py", label="Artist Library", icon="📚"
    )


def artist_stats_nav():
    st.sidebar.page_link(
        "pages/02_Artist_Stats.py", label="Artist Stats", icon="📊"
    )

# ---- Role: usaid_worker -----------------------------------------------------

def usaid_worker_home_nav():
    st.sidebar.page_link(
        "pages/10_USAID_Worker_Home.py", label="USAID Worker Home", icon="🏠"
    )


def ngo_directory_nav():
    st.sidebar.page_link("pages/14_NGO_Directory.py", label="NGO Directory", icon="📁")


def add_ngo_nav():
    st.sidebar.page_link("pages/15_Add_NGO.py", label="Add New NGO", icon="➕")


def prediction_nav():
    st.sidebar.page_link(
        "pages/11_Prediction.py", label="Regression Prediction", icon="📈"
    )


def api_test_nav():
    st.sidebar.page_link("pages/12_API_Test.py", label="Test the API", icon="🛜")


def classification_nav():
    st.sidebar.page_link(
        "pages/13_Classification.py", label="Classification Demo", icon="🌺"
    )


# ---- Role: label_head -------------------------------------------------------

def label_head_home_nav():
    st.sidebar.page_link(
        "pages/30_Label_Head_Home.py", label="Label Head Home", icon="🎵"
    )


def royalty_splits_nav():
    st.sidebar.page_link(
        "pages/31_Royalty_Splits.py", label="Royalty Splits", icon="💸"
    )


def asset_tracker_nav():
    st.sidebar.page_link(
        "pages/32_Asset_Tracker.py", label="Asset Tracker", icon="📂"
    )


def release_overview_nav():
    st.sidebar.page_link(
        "pages/33_Release_Overview.py", label="Release Overview", icon="📀"
    )


# ---- Role: administrator ----------------------------------------------------

def admin_home_nav():
    st.sidebar.page_link("pages/20_Admin_Home.py", label="System Admin", icon="🖥️")


def ml_model_mgmt_nav():
    st.sidebar.page_link(
        "pages/21_ML_Model_Mgmt.py", label="ML Model Management", icon="🏢"
    )


# ---- Sidebar assembly -------------------------------------------------------

def SideBarLinks(show_home=False):
    """
    Renders sidebar navigation links based on the logged-in user's role.
    The role is stored in st.session_state when the user logs in on Home.py.
    """

    # Logo appears at the top of the sidebar on every page
    st.sidebar.image("assets/brand/audiovate_logo.png", width=150)

    # If no one is logged in, send them to the Home (login) page
    if "authenticated" not in st.session_state:
        st.session_state.authenticated = False
        st.switch_page("Home.py")

    if show_home:
        home_nav()

    if st.session_state["authenticated"]:

        if st.session_state["role"] == "artist":
            artist_home_nav()
            artist_library_nav()
            artist_stats_nav()
        
        if st.session_state["role"] == "data_analyst":
            pass

        if st.session_state["role"] == "label_head":
            label_head_home_nav()
            royalty_splits_nav()
            asset_tracker_nav()
            release_overview_nav()

        if st.session_state["role"] == "admin":
            admin_home_nav()
            ml_model_mgmt_nav()

    # About link appears at the bottom for all roles
    about_page_nav()

    if st.session_state["authenticated"]:
        if st.sidebar.button("Logout"):
            del st.session_state["role"]
            del st.session_state["authenticated"]
            st.switch_page("Home.py")
