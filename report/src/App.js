import React, { Component } from "react";
import logo from "./pullapprove-logo.png";
import "./App.scss";
import Config from "./components/Config.js";
import Groups from "./components/Groups.js";
import Status from "./components/Status.js";
import Start from "./components/Start.js";
import StatusJSON from "./components/StatusJSON.js";
import { contextForStatus } from "./context.js";

export const AppContext = React.createContext();

class App extends Component {
  state = { status: null, tab: "groups", embedded: false, error: null };
  componentDidMount() {
    const windowURL = new URL(window.location.href);
    const s = windowURL.searchParams.get("s");
    const url = windowURL.searchParams.get("url");
    const truncatedStorageUrl = windowURL.searchParams.get("t");
    if (s) {
      const d = decodeURIComponent(s);
      const decoded = atob(d);
      this.loadStatusFromText(decoded);
    } else if (url) {
      this.loadStatusFromURL(decodeURI(url));
    } else if (truncatedStorageUrl) {
      // Only used in enterprise
      const suffix = window.location.hostname.match(/pullapprove-public-(\w+)/)[1];
      const base = `https://pullapprove-storage-${suffix}.s3.amazonaws.com/reports/`;
      this.loadStatusFromURL(base + decodeURI(truncatedStorageUrl));
    }

    this.setState({ embedded: windowURL.searchParams.get("embedded") });
  }
  loadStatusFromText = text => {
    const data = JSON.parse(text);
    this.setState({ status: data });
  };
  loadStatusFromURL = url => {
    const t = this;
    fetch(url)
      .then(function(response) {
        return response.json();
      })
      .then(function(data) {
        t.setState({ status: data });
      })
      .catch(error => {
        console.error(error);
        t.setState({ error: error });
      });
  };
  render() {
    if (this.state.error) {
      throw this.state.error;
    }

    if (!this.state.status) {
      return (
        <Start
          loadFromTextHandler={this.loadStatusFromText}
          loadFromURLHandler={this.loadStatusFromURL}
          embedded={this.state.embedded}
        />
      );
    }

    return (
      <div
        className={
          this.state.embedded ? "container-fluid" : "container mt-sm-4"
        }
      >
        <AppContext.Provider value={contextForStatus(this.state.status)}>
          <div className="mb-sm-4 d-flex align-items-center border-bottom pb-2">
            <h1 className="font-weight-light">
              {this.state.status.repo.full_name} #
              {this.state.status.pull_request.number}
            </h1>
            {!this.state.embedded ? (
              <img
                className="ml-auto d-none d-sm-block"
                src={logo}
                style={{ maxHeight: "25px" }}
                alt="PullApprove logo"
              />
            ) : null}
          </div>

          {this.state.status.meta.mode === "test" ? (
            <div className="my-4 alert alert-warning">
              <strong>You are in test mode!</strong> The status below is an
              example of what would happen if you used this configuration.
            </div>
          ) : null}

          {this.state.status.status ? (
            <div className="my-4">
              <Status
                state={this.state.status.status.state}
                explanation={this.state.status.status.explanation}
              />
            </div>
          ) : null}

          <ul className="nav nav-tabs">
            <li className="nav-item">
              <a
                className={
                  this.state.tab === "groups" ? "nav-link active" : "nav-link"
                }
                onClick={() => this.setState({ tab: "groups" })}
                href="#"
              >
                Groups
              </a>
            </li>
            <li className="nav-item">
              <a
                className={
                  this.state.tab === "config" ? "nav-link active" : "nav-link"
                }
                onClick={() => this.setState({ tab: "config" })}
                href="#"
              >
                Config
              </a>
            </li>
            <li className="nav-item">
              <a
                className={
                  this.state.tab === "debug" ? "nav-link active" : "nav-link"
                }
                onClick={() => this.setState({ tab: "debug" })}
                href="#"
              >
                Debug
              </a>
            </li>
          </ul>

          <div className="pt-4">
            {this.state.tab === "groups" ? (
              <Groups data={this.state.status.status.groups} />
            ) : null}
            {this.state.tab === "config" ? (
              <Config data={this.state.status.config} />
            ) : null}
            {this.state.tab === "debug" ? (
              <StatusJSON data={this.state.status} />
            ) : null}
          </div>
        </AppContext.Provider>
      </div>
    );
  }
}

export default App;
