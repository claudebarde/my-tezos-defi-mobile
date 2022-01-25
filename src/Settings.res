open Dom.Storage2

@val external localStorage: Dom.Storage2.t = "localStorage"

@react.component
let make = (~user_address: option<string>=?, ~set_user_address) => {
    <div>
        <div>{"Settings"->React.string}</div>        
        {
            switch user_address {
                | None => React.null
                | Some(_) => 
                    <div>
                        <div>{"Disconnect your account"->React.string}</div>
                        <button className="primary" onClick={_ => {
                            let _ = set_user_address(_ => None)
                            let _ = localStorage->removeItem(Config.ls_prefix ++ Config.ls_user_address)
                            RescriptReactRouter.push("/")
                        }}>
                            {"Disconnect"->React.string}
                        </button>
                    </div>
            }
        }
    </div>
}