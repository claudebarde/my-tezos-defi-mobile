open Promise
open AppContext

@val external require: string => string = "require"
require("../../../../src/TokensBanner/TokensBanner.scss")->ignore

@react.component
let make = () => {
    let state = React.useContext(StateContext.context)
    let update_context = React.useContext(DispatchContext.context)
    
    let fetch_tokens_data = (): unit => {
        let query = "https://api.teztools.io/v1/prices"
        Fetch.fetch(query)
            ->then(Fetch.Response.json)
            ->then(json => {
                switch json->Js.Json.decodeObject {
                    | None => Js.log("No tokens data received")
                    | Some(obj) => 
                        switch obj->Js.Dict.get("contracts") {
                            | None => Js.log("Tokens data has no `contracts` key")
                            | Some(contracts) =>
                                switch contracts->Js.Json.decodeArray {
                                    | None => Js.log("Tokens data is not an array")
                                    | Some(d) => {
                                        let tokens_data = []
                                        let _ = 
                                            d->Js.Array2.filter(
                                                token => switch token->Js.Json.decodeObject {
                                                    | None => false
                                                    | Some(tk) =>
                                                        switch tk->Js.Dict.get("symbol") {
                                                            | None => false
                                                            | Some(symbol) => 
                                                                switch symbol->Js.Json.decodeString {
                                                                    | None => false
                                                                    | Some(sym) => Js.Array2.includes(Config.available_tokens, sym)
                                                                }
                                                        }
                                                }
                                            )
                                            ->Js.Array2.forEach(
                                                tk => switch tk->Js.Json.decodeObject {
                                                    | None => ()
                                                    | Some(obj) => {
                                                        let new_obj: token_data = {
                                                            name: 
                                                                switch obj->Js.Dict.get("symbol") {
                                                                    | None => None
                                                                    | Some(sym) => {
                                                                        switch sym->Js.Json.decodeString {
                                                                            | None => None
                                                                            | Some(r) => Some(r)
                                                                        }
                                                                    }
                                                                },
                                                            exchange_rate: 
                                                                switch obj->Js.Dict.get("currentPrice") {
                                                                    | None => None
                                                                    | Some(sym) => {
                                                                        switch sym->Js.Json.decodeNumber {
                                                                            | None => None
                                                                            | Some(r) => Some(r)
                                                                        }
                                                                    }
                                                                },
                                                            address: 
                                                                switch obj->Js.Dict.get("address") {
                                                                    | None => None
                                                                    | Some(addr) => {
                                                                        switch addr->Js.Json.decodeString {
                                                                            | None => None
                                                                            | Some(r) => Some(r)
                                                                        }
                                                                    }
                                                                },
                                                            type_: 
                                                                switch obj->Js.Dict.get("type") {
                                                                    | None => None
                                                                    | Some(t) =>
                                                                        switch t->Js.Json.decodeString {
                                                                            | None => None
                                                                            | Some(r) => 
                                                                                if r === "fa2" {
                                                                                    FA2
                                                                                } else {
                                                                                    FA12
                                                                                }
                                                                        }                                                                        
                                                                },
                                                            decimals:
                                                                switch obj->Js.Dict.get("decimals") {
                                                                    | None => None
                                                                    | Some(sym) => {
                                                                        switch sym->Js.Json.decodeNumber {
                                                                            | None => None
                                                                            | Some(r) => Some(r->Belt.Int.fromFloat)
                                                                        }
                                                                    }
                                                                }
                                                        }
                                                        let _ = Js.Array2.push(tokens_data, new_obj)
                                                        ()
                                                    }
                                                }
                                            )
                                            Update_tokens(tokens_data)->update_context
                                    }
                                } 
                        }
                }->resolve
            })
            ->catch(err => Js.log(err)->resolve)
            ->ignore
    }

    React.useEffect0(() => {
        // fetches tokens data
        let _ = fetch_tokens_data()

        None
    })

    <div className="slider">
        <div className="slide-track">
            {
                if state.tokens->Js.Array2.length === 0 {
                    <div>{"Token banner placeholder"->React.string}</div>
                } else {
                    state.tokens
                    ->Js.Array2.map(
                        token =>
                            {
                                switch token.name {
                                    | None => React.null
                                    | Some(name) => 
                                        <div key={name} className="slide">
                                            <div>
                                                <img src={"img/images/" ++ name ++ ".png"} />
                                            </div>
                                            <div>
                                                <div>{name->React.string}</div>
                                                <div className="exchange-rate">
                                                    {
                                                        switch token.exchange_rate {
                                                            | None => "N/A"->React.string
                                                            | Some(rate) => rate->Js.Float.toFixedWithPrecision(~digits=5)->React.string
                                                        }
                                                    }
                                                </div>
                                            </div>
                                        </div>
                                }
                            }
                    )
                    ->React.array
                }
            }
        </div>
    </div>
}