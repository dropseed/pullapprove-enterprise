import React, { Component } from "react";

class LoadURL extends Component {
  state = { content: "" };
  load = () => {
    try {
      this.props.loadHandler(this.state.content);
    } catch (e) {
      alert(e);
      return;
    }
  };
  render() {
    return (
      <div className="card card-body">
        <p>Paste the URL to a PullApprove status JSON.</p>
        <textarea
          rows={5}
          style={{ fontSize: ".9rem" }}
          className="form-control"
          value={this.state.content}
          onChange={e => this.setState({ content: e.target.value })}
        />
        <button className="btn btn-primary mt-1" onClick={this.load}>
          Load URL
        </button>
      </div>
    );
  }
}

export default LoadURL;
