open Promise

module Valid_currencies = {
    type currency = 
    | USD
    | EURO
    | CAD
    | GBP
    | SGD
    | RUB
    | CNY
    | BTC
}

let format_token_amount = (amount: float): result<float, string> => {
    switch amount->Js.Float.toFixedWithPrecision(~digits=5)->Belt.Float.fromString {
        | None => Error("N/A")
        | Some(num) => Ok(num /. 1.0)
    }
}

let format_currency_amount = (amount: float): result<float, string> => {
    switch amount->Js.Float.toFixedWithPrecision(~digits=2)->Belt.Float.fromString {
        | None => Error("N/A")
        | Some(num) => Ok(num /. 1.0)
    }
}

let fetch_xtz_exchange_rate = (vs_currency: Valid_currencies.currency, dispatch: (AppContext.action) => ()) => {
    let base_url = "https://api.coingecko.com/api/v3/simple/price?ids=tezos&vs_currencies="
    let currency = switch vs_currency {
        | USD => "usd"
        | EURO => "eur"
        | CAD => "cad"
        | GBP => "gbp"
        | SGD => "sgd"
        | RUB => "rub"
        | CNY => "cny"
        | BTC => "btc"
    }

    Fetch.fetch(base_url ++ currency)
        ->then(Fetch.Response.json)
        ->then(json => {
            switch json->Js.Json.decodeObject {
                | None => {
                    Js.log("No JSON received for XTZ exchange rate")
                    dispatch(AppContext.Update_xtz_exchange_rate(None))
                }
                | Some(obj) =>
                    switch obj->Js.Dict.get("tezos") {
                        | None => {
                            Js.log("No 'tezos' property on JSON for XTZ exchange rate")
                            dispatch(AppContext.Update_xtz_exchange_rate(None))
                        }
                        | Some(tezos) =>
                            switch tezos->Js.Json.decodeObject {
                                | None => {
                                    Js.log("'tezos' property in JSON for XTZ exchange rate is not an object")
                                    dispatch(AppContext.Update_xtz_exchange_rate(None))
                                }
                                | Some(obj) => 
                                    switch obj->Js.Dict.get(currency) {
                                        | None => {
                                            Js.log(`No '${currency}' property in JSON for XTZ exchange rate`)
                                            dispatch(AppContext.Update_xtz_exchange_rate(None))
                                        }
                                        | Some(rate) =>
                                            switch rate->Js.Json.decodeNumber {
                                                | None => {
                                                    Js.log("Received rate for XTZ exchange rate is not a number")
                                                    dispatch(AppContext.Update_xtz_exchange_rate(None))
                                                }
                                                | Some(num) => dispatch(AppContext.Update_xtz_exchange_rate(Some(num)))
                                            }
                                    }
                            }
                    }
            }->resolve
        })
        ->catch(err => {
            Js.log(err)
            dispatch(AppContext.Update_xtz_exchange_rate(None))
            resolve()
        })
        ->ignore
}