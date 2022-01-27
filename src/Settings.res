open Dom.Storage2
open Context

@val external localStorage: Dom.Storage2.t = "localStorage"

@react.component
let make = () => {
    let state = React.useContext(StateContext.context)
    let update_context = React.useContext(DispatchContext.context)

    <div>
        <div>{"Settings"->React.string}</div>        
        {
            switch state.user_address {
                | None => React.null
                | Some(_) => 
                    <div>
                        <div>{"Disconnect your account"->React.string}</div>
                        <button className="primary" onClick={_ => {
                            let _ = update_context(Update_user_address(None))
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