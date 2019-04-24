import React, { Component } from "react";
import SyntaxHighlighter from "react-syntax-highlighter";

class Config extends Component {
  render() {
    return (
      <SyntaxHighlighter language="yaml">
        {this.props.data.config_text || ""}
      </SyntaxHighlighter>
    );
  }
}

export default Config;
