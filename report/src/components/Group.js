import React, { Component } from "react";
import { textColor } from "../colors.js";
import Conditions from "./Conditions.js";
import { AppContext } from "../App.js";
import marked from "marked";
import dompurify from "dompurify";

class Group extends Component {
  state = { showAllUsers: false };
  userRows(users, state) {
    if (state === "available" && !this.state.showAllUsers) return;
    return users.map(username => (
      <tr key={username}>
        <td width="200px">
          <AppContext.Consumer>
            {context => (
              <img
                src={context.avatarUrlFormat.replace("{username}", username)}
                alt=""
                height="22px"
                className="mr-1"
                style={{ borderRadius: "3px", verticalAlign: "inherit" }}
              />
            )}
          </AppContext.Consumer>
          {username}
        </td>
        <td className={textColor(state)}>{state}</td>
      </tr>
    ));
  }
  render() {
    const { name, data } = this.props;
    return (
      <div className="card mb-4">
        <div className="card-header">
          <strong>{name}</strong> &mdash; {data.score} of {data.required}{" "}
          required
          <div className="float-right">
            <span
              className={
                data.is_active ? "badge badge-success" : "badge badge-secondary"
              }
            >
              {data.is_active ? "active" : "inactive"}
            </span>
            &nbsp;
            <span
              className={
                data.is_active && data.is_passing
                  ? "badge badge-success"
                  : "badge badge-secondary"
              }
            >
              {data.state}
            </span>
          </div>
        </div>

        <div className="card-body">

          {data.description ? <div className="mb-4" dangerouslySetInnerHTML={{__html: dompurify.sanitize(marked(data.description))}} /> : null}

          <div className="row">
            <div className="col-sm-6">
              <h5 className="card-title float-left">Reviewers</h5>

              <div className="form-group form-check float-right mb-0">
                <input
                  type="checkbox"
                  className="form-check-input"
                  id={`showUsersCheck-${name}`}
                  value={this.state.showAllUsers}
                  onChange={() =>
                    this.setState({ showAllUsers: !this.state.showAllUsers })
                  }
                />
                <label
                  className="form-check-label"
                  htmlFor={`showUsersCheck-${name}`}
                >
                  <small>Show all users</small>
                </label>
              </div>

              <table className="table table-flush">
                <tbody>
                  {this.userRows(data.users_rejected, "rejected")}
                  {this.userRows(data.users_approved, "approved")}
                  {this.userRows(data.users_pending, "pending")}
                  {this.userRows(data.users_unavailable, "unavailable")}
                  {this.userRows(data.users_available, "available")}
                </tbody>
              </table>
            </div>
            <div className="col-sm-6">
              <h5 className="card-title">Conditions</h5>
              <Conditions data={data.conditions} />

              <h5 className="card-title">Settings</h5>
              <dl className="row">
                <dt className="col-sm-4">
                  <code>required</code>
                </dt>
                <dd className="col-sm-8">
                  <code>{data.required}</code>
                </dd>

                <dt className="col-sm-4">
                  <code>request</code>
                </dt>
                <dd className="col-sm-8">
                  <code>{data.request}</code>
                </dd>

                <dt className="col-sm-4">
                  <code>request_order</code>
                </dt>
                <dd className="col-sm-8">
                  <code>{data.request_order}</code>
                </dd>

                <dt className="col-sm-4">
                  <code>author_value</code>
                </dt>
                <dd className="col-sm-8">
                  <code>{data.author_value}</code>
                </dd>

                <dt className="col-sm-4">
                  <code>reviewed_for</code>
                </dt>
                <dd className="col-sm-8">
                  <code>{data.reviewed_for}</code>
                </dd>
              </dl>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default Group;
