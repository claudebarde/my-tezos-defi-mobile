@val external require: string => string = "require"

require("../../../src/Footer.scss")->ignore

@react.component
let make = (~user_address: option<string>=?) => {
    <footer>
        <button className="footer_button" onClick={_ => RescriptReactRouter.push("/")}>
            <span className="material-icons"> {"home"->React.string} </span>
        </button>
        {
            switch user_address {
                | None => React.null
                | Some(_) => {
                    <>
                        <button className="footer_button" onClick={_ => RescriptReactRouter.push("/tokens")}>
                            <span className="material-icons"> {"toll"->React.string} </span>
                        </button>
                        <button className="footer_button" onClick={_ => RescriptReactRouter.push("/farms")}>
                            <span className="material-icons"> {"agriculture"->React.string} </span>
                        </button>
                    </>
                }
            }
        }
        <button className="footer_button" onClick={_ => RescriptReactRouter.push("/settings")}>
            <span className="material-icons"> {"settings"->React.string} </span>
        </button>
    </footer>
}