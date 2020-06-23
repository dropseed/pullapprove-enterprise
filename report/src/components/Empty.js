import React, { Component } from "react";
import feather from "feather-icons";

class Empty extends Component {
  render() {
    let svg = null;
    if (this.props.icon) {
      svg = feather.icons[this.props.icon].toSvg({
        width: 40,
        height: 40,
      });
    }
    return (
      <div className="text-center text-muted py-5">
        <h2>
          {svg ? (
            <React.Fragment>
              <span dangerouslySetInnerHTML={{ __html: svg }} />
              <br />
            </React.Fragment>
          ) : null}
          {this.props.text}
        </h2>
      </div>
    );
  }
}

export default Empty;
