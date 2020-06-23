import React, { Component } from "react";
import { textColor } from "../colors.js";

class Expressions extends Component {
  render() {
    const { data } = this.props;
    if (data.length < 1) {
      return <div className="text-muted mb-3">None</div>;
    }
    return (
      <table className="table table-flush">
        <tbody>
          {data.map((c) => (
            <tr key={c.condition || c.expression}>
              <td width="30px" className={textColor(c.is_met)}>
                {c.is_met ? "pass" : "fail"}
              </td>
              <td>
                <code>{c.condition || c.expression}</code>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    );
  }
}

export default Expressions;
