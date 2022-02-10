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

module ParseJson = {
    type rec data_type =
        | Obj(string) // with the key to find in the object
        | Number
        | String
        | Array(int, data_path) // with the index to find if not negative
        | Array_map(data_path)
    and data_path = list<data_type>

    type return = result<array<string>, string>

    let rec parse_json = (json: Js.Json.t, path: data_path): return => {
        switch path {
            | list{} => Error("empty path")
            | list{element} => {
                switch element {
                    | Number => 
                        switch json->Js.Json.decodeNumber {
                            | None => Error("Value is not a number")
                            | Some(v) => Ok([v->Belt.Float.toString])
                        }
                    | String => 
                        switch json->Js.Json.decodeString {
                            | None => Error("Value is not a string")
                            | Some(v) => Ok([v])
                        }
                    | Array(index, path) => 
                        switch json->Js.Json.decodeArray {
                            | None => Error("Value is not an array")
                            | Some(arr) => parse_json(arr[index], path)
                        }
                    | Array_map(action) => array_map(json, action)
                    | _ => Error("JSON element cannot be an object at this point")
                }
            }
            | list{head, ...tail} =>
                switch head {
                    | Number => 
                        switch json->Js.Json.decodeNumber {
                            | None => Error("Value is not a number")
                            | Some(v) => Ok([v->Belt.Float.toString])
                        }
                    | String => 
                        switch json->Js.Json.decodeString {
                            | None => Error("Value is not a string")
                            | Some(v) => Ok([v])
                        }
                    | Obj(key) => 
                        switch json->Js.Json.decodeObject {
                            | None => Error("Value is not an object")
                            | Some(obj) => 
                                switch obj->Js.Dict.get(key) {
                                    | None => Error(`Key "${key}" doesn't exist on object`)
                                    | Some(v) => parse_json(v, tail)
                                }
                        }
                    | Array(index, path) => 
                        switch json->Js.Json.decodeArray {
                            | None => Error("Value is not an array")
                            | Some(arr) => parse_json(arr[index], path)
                        }
                    | Array_map(action) => array_map(json, action)
                }
        }        
    } and array_map = (json: Js.Json.t, action: data_path): return => 
        switch json->Js.Json.decodeArray {
            | None => Error("Value is not an array")
            | Some(arr) => {
                let result = arr->Js.Array2.map(el => parse_json(el, action))
                if result
                    ->Js.Array2.filter(el => switch el { | Ok(_) => false | Error(_) => true })
                    ->Js.Array2.length > 0 {
                        // TODO
                        Error("An error occurred when mapping the array")
                    } else {
                        Ok(result->Js.Array2.map(el => switch el { | Ok(v) => v[0] | Error(_) => "" }))
                    }
            }
        }
}

module ParseDate = {
    let fromIsoString = (isoDate: string): string => {
        open Js.Date

        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        let formatDay = (dayNum: float): string => {
            if dayNum === 1.0 {
                "1st"
            } else if dayNum === 2.0 {
                "2nd"
            } else if dayNum === 3.0 {
                "3rd"
            } else if dayNum === 21.0 {
                "21st"
            } else if dayNum === 31.0 {
                "31st"
            } else {
                dayNum->Belt.Float.toString ++ "st"
            }
        }

        let day = isoDate->fromString->getDate->formatDay
        let month = isoDate->fromString->getMonth->{month => months[month->Belt.Float.toInt]}
        let year = isoDate->fromString->getFullYear->Belt.Float.toString
        let hours = isoDate->fromString->getHours->Belt.Float.toString
        let minutes = isoDate->fromString->getMinutes->Belt.Float.toString

        `${month} ${day}, ${year} at ${hours}:${minutes}`
    }
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

    // test for ParseJson module
    /*let _ = Fetch.fetch(base_url ++ currency)
            ->then(Fetch.Response.json)
            ->then(json => {
                let path = list{ParseJson.Obj("tezos"), ParseJson.Obj("usd"), ParseJson.Number}
                switch ParseJson.parse_json(json, path) {
                    | Ok(res) => Js.log(`OK -> ${res[0]}`)
                    | Error(err) => Js.log(`Error => ${err}`)
                }->resolve
            })
            ->catch(err => {
                Js.log(err)
                resolve()
            })
            ->ignore*/

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