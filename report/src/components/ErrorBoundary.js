import React, { Component } from "react";
import logo from "../pullapprove-logo.png";
import * as Sentry from "@sentry/browser";

class ErrorBoundary extends Component {
  constructor(props) {
    super(props);
    this.state = { error: null };
  }

  componentDidCatch(error, errorInfo) {
    this.setState({ error });
    Sentry.withScope((scope) => {
      Object.keys(errorInfo).forEach((key) => {
        scope.setExtra(key, errorInfo[key]);
      });
      Sentry.captureException(error);
    });
  }

  render() {
    if (this.state.error) {
      return (
        <div className="text-center my-5">
          <img
            src={logo}
            style={{ maxHeight: "50px" }}
            alt="PullApprove logo"
          />
          <p className="text-danger mt-3">There was an error loading the PR.</p>
          <a
            className="btn btn-outline-primary"
            href="https://www.pullapprove.com/contact/"
          >
            Report feedback
          </a>
        </div>
      );
    } else {
      // when there's not an error, render children untouched
      return this.props.children;
    }
  }
}

export default ErrorBoundary;
