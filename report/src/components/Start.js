import React, { Component } from "react";
import logo from "../pullapprove-logo.png";
import LoadJSON from "./LoadJSON.js";
import LoadURL from "./LoadURL.js";

class Start extends Component {
  state = {tab: null}
  render() {
    return (
      <div className="text-center mx-auto" style={{ maxWidth: "600px" }}>
        {!this.props.embedded ? (
          <img
            src={logo}
            style={{ maxHeight: "50px" }}
            alt="PullApprove logo"
            className="mt-5 mb-3"
          />
        ) : null}
        <p className="mt-4 text-muted mx-auto">
          View the status of a PR by clicking the link on a commit status.
          <br />
          <small>
            Or manually load from <a href="#" className="text-muted" onClick={() => this.setState({tab: "json"})}>JSON</a>
            {' '}or{' '}
            <a href="#" className="text-muted" onClick={() => this.setState({tab: "url"})}>URL</a>
          </small>
        </p>
        {this.state.tab === "json" ? <LoadJSON loadHandler={this.props.loadFromTextHandler} /> : null}
        {this.state.tab === "url" ? <LoadURL loadHandler={this.props.loadFromURLHandler} /> : null}
      </div>
    );
  }
}

export default Start;
