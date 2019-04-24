import React, { Component } from "react";
import SyntaxHighlighter from "react-syntax-highlighter";

class StatusJSON extends Component {
  render() {
    return (
      <SyntaxHighlighter language="json">
        {JSON.stringify(this.props.data, null, 2)}
      </SyntaxHighlighter>
    );
  }
}

export default StatusJSON;
