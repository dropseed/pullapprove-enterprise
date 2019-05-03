import React, { Component } from "react";

class LoadStatus extends Component {
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
        <p>Paste the JSON output to load a PR manually.</p>
        <textarea
          rows={10}
          style={{ fontSize: ".9rem" }}
          className="form-control"
          value={this.state.content}
          onChange={e => this.setState({ content: e.target.value })}
        />
        <button className="btn btn-primary mt-1" onClick={this.load}>
          Load JSON
        </button>
      </div>
    );
  }
}

export default LoadStatus;
