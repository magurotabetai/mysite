import "./main.css";
import "normalize.css/normalize.css";
import "@fortawesome/fontawesome-free-webfonts/css/fontawesome.css";
import "@fortawesome/fontawesome-free-webfonts/css/fa-brands.css";
import "@fortawesome/fontawesome-free-webfonts/css/fa-regular.css";
import "@fortawesome/fontawesome-free-webfonts/css/fa-solid.css";
import { Main } from "./Main.elm";
import registerServiceWorker from "./registerServiceWorker";

Main.embed(document.getElementById("root"));

registerServiceWorker();
