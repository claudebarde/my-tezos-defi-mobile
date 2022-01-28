open Promise
open AppContext

@val external require: string => string = "require"
require("../../../../src/Header/Header.scss")->ignore

@react.component
let make = () => {
    let state = React.useContext(StateContext.context)
    let update_context = React.useContext(DispatchContext.context)
    
    let fetch_balance = (user_address: string): unit => {
        let query = "https://api.tzkt.io/v1/accounts/" ++ user_address ++ "/balance"
        Fetch.fetch(query)
            ->then(Fetch.Response.text)
            ->then(balance => {
                switch balance->Belt.Float.fromString {
                    | None => Update_user_balance(Error("Couldn't convert balance to float"))->update_context
                    | Some (blnc) => Update_user_balance(Ok(blnc))->update_context
                }->resolve
            })
            ->catch(err => {
                Js.log(err)
                update_context(Update_user_balance(Error("Unable to fetch user's balance")))->resolve
            })
            ->ignore
    }

    React.useEffect1(() => {
        let _ = 
            switch state.user_address {
                | None => Update_user_balance(Error("No user"))->update_context
                | Some(addr) => fetch_balance(addr)           
            }

        None
    }, [state.user_address])

    <header>
        {
            switch state.user_balance {
                | Error(_) => 
                    <div>
                        {React.string("My Tezos DeFi")}
                        <br />
                        {React.string("Your DeFi tracking app")}
                    </div>
                | Ok(blnc) =>
                    <div className="balance">
                        <div>
                            {"Your balance:"->React.string}
                        </div>
                        <div className="balance_value">
                            {(blnc /. Js.Math.pow_float(~base=10.0, ~exp=6.0))->Belt.Float.toString->React.string}
                        </div>
                    </div>
            }
        }
        <div>
            <img src="img/logo.png" alt="mtd-logo" />
        </div>
    </header>
}