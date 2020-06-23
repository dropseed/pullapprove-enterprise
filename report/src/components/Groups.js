import React, { Component } from "react";
import Group from "./Group.js";
import Empty from "./Empty.js";

class Groups extends Component {
  state = { showAll: false };
  render() {
    let groupNames = Object.keys(this.props.data);
    if (!this.state.showAll) {
      groupNames = groupNames.filter(
        (name) => this.props.data[name].is_active || this.state.showAll
      );
    }
    return (
      <div>
        <div className="form-group form-check float-right">
          <input
            type="checkbox"
            className="form-check-input"
            id="showAllCheck"
            value={this.state.showAll}
            onChange={() => this.setState({ showAll: !this.state.showAll })}
          />
          <label className="form-check-label" htmlFor="showAllCheck">
            Show inactive groups
          </label>
        </div>
        <div className="clearfix" />

        {groupNames.length < 1 ? (
          <Empty text="No active groups" icon="x" />
        ) : null}

        {groupNames.map((name) => (
          <Group key={name} name={name} data={this.props.data[name]} />
        ))}
      </div>
    );
  }
}

export default Groups;
