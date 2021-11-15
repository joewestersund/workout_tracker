// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"


import "../client_side/default_data_explanation"
import "../client_side/select_workout_type"

import "../stylesheets/colors.css.scss"
import "../stylesheets/forms.css.scss"
import "../stylesheets/framework_and_overrides.css.scss"
import "../stylesheets/navbar.css.scss"
import "../stylesheets/scaffolds.css.scss"
import "../stylesheets/select.css.scss"
import "../stylesheets/style.css.scss"
import "../stylesheets/tables.css.scss"
import "../stylesheets/will_paginate.css.scss"

import "@fortawesome/fontawesome-free/js/all"

Rails.start()
Turbolinks.start()
ActiveStorage.start()

require("jquery");
require("bootstrap");


// Support component names relative to this directory:
var componentRequireContext = require.context("components", true);
var ReactRailsUJS = require("react_ujs");
ReactRailsUJS.useContext(componentRequireContext);
