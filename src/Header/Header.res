open Promise

@val external require: string => string = "require"
require("../../../../src/Header/Header.scss")->ignore

@react.component
let make = () => {
    let state = React.useContext(Context.StateContext.context)
    let (user_balance, set_user_balance) = React.useState(_ => Error("init"))
    
    let fetch_balance = (user_address: string): unit => {
        let query = "https://api.tzkt.io/v1/accounts/" ++ user_address ++ "/balance"
        Fetch.fetch(query)
            ->then(Fetch.Response.text)
            ->then(balance => {
                switch balance->Belt.Float.fromString {
                    | None => set_user_balance(_ => Error("Couldn't convert balance to float"))
                    | Some (blnc) => set_user_balance(_ => Ok(blnc))
                }->resolve
            })
            ->catch(err => {
                Js.log(err)
                set_user_balance(_ => Error("Unable to fetch user's balance"))->resolve
            })
            ->ignore
    }

    React.useEffect1(() => {
        let _ = 
        switch state.user_address {
            | None => set_user_balance(_ => Error("No user"))            
            | Some(addr) => fetch_balance(addr)           
            }

        None
    }, [state.user_address])

    <header>
        {
            switch user_balance {
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
                            {blnc->Belt.Float.toString->React.string}
                        </div>
                    </div>
            }
        }
        <div>
            <img src="img/logo.png" alt="mtd-logo" />
        </div>
    </header>
}