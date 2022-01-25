open Dom.Storage2

@val external localStorage: Dom.Storage2.t = "localStorage"
@val external require: string => string = "require"
require("../../../../src/Home/Home_No_user.scss")->ignore

@react.component
let make = (~set_user_address) => {
    let (comp_user_address, set_comp_user_address) = React.useState(_ => "")

    let save_user_address = _ => {
        if comp_user_address->Js.String2.trim->Js.String2.length > 0 {
            localStorage->setItem(Config.ls_prefix ++ Config.ls_user_address, comp_user_address)
            set_user_address(_ => Some(comp_user_address->Js.String2.trim))
        }
    }

    <div className="container__home__no_user">
        <div className="address_input">
            <div>
                {"Insert your Tezos account address below"->React.string}
            </div>
            <input 
                type_="text" 
                value={comp_user_address} 
                onChange={ev => set_comp_user_address(ReactEvent.Form.currentTarget(ev)["value"])} 
            />
            <button className="primary" onClick={save_user_address}>{"Start"->React.string}</button>
        </div>
    </div>
}