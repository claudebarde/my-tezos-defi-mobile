open Promise

@val external require: string => string = "require"
require("../../../../src/Tokens/Tokens.scss")->ignore

type user_token = {
    name: string,
    balance: float,
    decimals: float
}

@react.component
let make = () => {
    let state = React.useContext(AppContext.StateContext.context)
    let (user_tokens, set_users_tokens) = React.useState(_ => [])

    let fetch_token_balances = () => {
        switch state.user_address {
            | None => ()
            | Some(addr) => {
                Js.log("fetch token balances")
                let query = "https://staging.api.tzkt.io/v1/tokens/balances?account=" ++ addr
                Fetch.fetch(query)
                    ->then(Fetch.Response.json)
                    ->then(json => 
                        switch json->Js.Json.decodeArray {
                            | None => Js.log("Value received for token balances is not an array")
                            | Some (arr) => {
                                arr->Js.Array2.forEach(val => {
                                    switch val->Js.Json.decodeObject {
                                        | None => Js.log("Token value is not an object")
                                        | Some(token) => {
                                            // gets token balance
                                            let balance: float = {
                                                switch token->Js.Dict.get("balance") {
                                                    | None => 0.0
                                                    | Some(blnc) => 
                                                        switch blnc->Js.Json.decodeString {
                                                            | None => 0.0
                                                            | Some(blnc) =>
                                                                switch blnc->Belt.Float.fromString {
                                                                    | None => 0.0
                                                                    | Some(blnc) => blnc
                                                                }
                                                        }
                                                }
                                            }
                                            switch token->Js.Dict.get("token") {
                                                | None => Js.log("Token doesn't have a 'token' property")
                                                | Some(tk) => {
                                                    switch tk->Js.Json.decodeObject {
                                                        | None => Js.log("token.token is undefined")
                                                        | Some (tk_tk) => {
                                                            switch tk_tk->Js.Dict.get("metadata") {
                                                                | None => Js.log("token.token.metadata is undefined")
                                                                | Some (tk_tk_contract) => {
                                                                    switch tk_tk_contract->Js.Json.decodeObject {
                                                                        | None => Js.log("token.token.contract is not an object")
                                                                        | Some (tk_tk_contract) => {
                                                                            let decimals_opt = tk_tk_contract->Js.Dict.get("decimals")
                                                                            switch tk_tk_contract->Js.Dict.get("symbol") {
                                                                                | None => Js.log2("token.token.contract.symbol is undefined", tk_tk_contract)
                                                                                | Some(tk_symbol) => {
                                                                                    switch tk_symbol->Js.Json.decodeString {
                                                                                        | None => Js.log("token.token.contract.symbol is not a string")
                                                                                        | Some(tk_symbol) => {
                                                                                            if Config.available_tokens->Js.Array2.includes(tk_symbol) {
                                                                                                switch decimals_opt {
                                                                                                    | None => Js.log("No decimals found for token" ++ tk_symbol)
                                                                                                    | Some(decimals) => {
                                                                                                        switch decimals->Js.Json.decodeString {
                                                                                                            | None => Js.log("Token decimals is not a string")
                                                                                                            | Some(decimals) =>
                                                                                                                switch decimals->Belt.Float.fromString {
                                                                                                                    | None => Js.log("Cannot format decimals to float")
                                                                                                                    | Some(decimals) =>
                                                                                                                        let formatted_balance = 
                                                                                                                            switch {balance /. Js.Math.pow_float(~base=10.0, ~exp=decimals)}->Utils.format_token_amount {
                                                                                                                                | Ok(val) => val
                                                                                                                                | Error(_) => 0.0
                                                                                                                            }
                                                                                                                        if formatted_balance > 0.0 {
                                                                                                                            set_users_tokens(_prev => [{
                                                                                                                                name: tk_symbol,
                                                                                                                                balance,
                                                                                                                                decimals
                                                                                                                            }]->Js.Array2.concat(_prev))         
                                                                                                                        }
                                                                                                                }                                                                                                                
                                                                                                        }
                                                                                                    }
                                                                                                }
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                }
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                })
                            }
                        }->resolve)
                    ->catch(err => Js.log(err)->resolve)
                    ->ignore
            }
        }
    }

    React.useEffect1(() => {
        fetch_token_balances()

        None
    }, [state.user_address])

    <div className="user-tokens">
        <div>{React.string("Your tokens")}</div>
        <div className="tokens-list">
            {
                user_tokens
                    ->Js.Array2.map(token => {
                        <div key={token.name} className="tokens-list__token">
                            <img src={`img/images/${token.name}.png`} alt={`${token.name}-logo`} />
                            <div className="tokens-list__token__price">
                                <div>
                                    {token.name->React.string}
                                </div>
                                <div className="xtz-symbol">
                                    {
                                        switch state.tokens->Js.Array2.find(tk => tk.name === Some(token.name)) {
                                            | None => "N/A"
                                            | Some(tk) =>
                                                switch tk.exchange_rate {
                                                    | None => "N/A"
                                                    | Some(rate) => 
                                                        switch rate->Utils.format_token_amount {
                                                            | Ok(val) => val->Belt.Float.toString
                                                            | Error(_) => "N/A"
                                                        }
                                                }
                                        }->React.string
                                    }
                                </div>
                            </div> 
                            <div>
                                {
                                    switch {token.balance /. Js.Math.pow_float(~base=10.0, ~exp=token.decimals)}
                                        ->Utils.format_token_amount {
                                            | Ok(val) => val->Belt.Float.toString->React.string
                                            | Error(val) => val->React.string
                                        }                                                
                                }
                            </div>
                        </div>
                    })
                    ->React.array
            }
        </div>
    </div>
}