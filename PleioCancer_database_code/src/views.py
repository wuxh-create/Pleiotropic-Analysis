# src/views.py
from flask import Blueprint
from flask import render_template

views = Blueprint(
    "view", __name__,
    template_folder = "templates",
    static_folder   = "static",
    static_url_path = "/"
)

@views.route("/")
def main():
    return render_template("index.html")

@views.app_errorhandler(404)
def handle_404(e):
    return render_template("index.html")

@views.app_errorhandler(500)
def handle_505(e):
    return render_template("505.html")