import React, { Component } from "react";
import { colors } from "../colors.js";

class Status extends Component {
  render() {
    return (
      <div className={"alert alert-" + colors[this.props.state]}>
        {this.props.state} &mdash; {this.props.explanation}
      </div>
    );
  }
}

export default Status;
