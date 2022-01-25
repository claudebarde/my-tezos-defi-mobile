open Promise

@val external require: string => string = "require"
require("../../../src/Header.scss")->ignore

@react.component
let make = (~user_address: option<string>=?) => {
    let (user_balance, set_user_balance) = React.useState(_ => None)

    let fetch_balance = (user_address: string) => {
        let query = "https://api.tzkt.io/v1/accounts/" ++ user_address ++ "/balance"
        let _ = Promise.make((_, _) => {
            Fetch.fetch(query)
            ->then(Fetch.Response.text)
            ->thenResolve(balance => {
                set_user_balance(_ => balance->Belt.Float.fromString)
            })
            ->ignore
        })
    }

    <header>
        {
            switch user_address {
            | None => 
                <div>
                    {React.string("My Tezos DeFi")}
                    <br />
                    {React.string("Your DeFi tracking app")}
                </div>
            | Some(addr) => 
                let _ = fetch_balance(addr)                
                {
                    switch user_balance {
                        | None => <div>{"No balance"->React.string}</div>
                        | Some(blnc) => {
                            let formatted_balance = (blnc /. Js.Math.pow_float(~base=10.0, ~exp=6.0))->Belt.Float.toString
                            let balance_text = formatted_balance

                            <div className="balance">
                                <div>
                                    {"Your balance:"->React.string}
                                </div>
                                <div className="balance_value">
                                    {balance_text->React.string}
                                </div>
                            </div>
                        }
                    }
                }               
            }
        }
        <div>
            <img src="img/logo.png" alt="mtd-logo" />
        </div>
    </header>
}