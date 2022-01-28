open Promise

@val external require: string => string = "require"
require("../../../../src/Home/Home_Connected.scss")->ignore

type delegate_status =
    | Active_delegate
    | Inactive_delegate
    | Unknown_delegate

type activity_data = {
    alias: option<string>,
    delegate: option<(string, string, delegate_status)>,
    token_transfers_count: option<int>,
    transactions_count: option<int>,
    first_activity: option<(string, int)>,
    last_activity: option<(string, int)>
}

let empty_activity = {
    alias: None,
    delegate: None,
    token_transfers_count: None,
    transactions_count: None,
    first_activity: None,
    last_activity: None
}

@react.component
let make = () => {
    let state = React.useContext(AppContext.StateContext.context)
    let update_context = React.useContext(AppContext.DispatchContext.context)
    let (activity, set_activity) = React.useState(_ => empty_activity)

    let fetch_activity = (user_address: string): unit => {
        let query = "https://staging.api.tzkt.io/v1/accounts/" ++ user_address
        Fetch.fetch(query)
            ->then(Fetch.Response.json)
            ->then(
                json => switch json->Js.Json.decodeObject {
                    | None => set_activity(_ => empty_activity)->resolve
                    | Some(obj) => {
                        // initializes activity data
                        let activity_data: activity_data = activity
                        // find user's alias
                        let activity_data = switch obj->Js.Dict.get("alias") {
                            | None => { ...activity_data, alias: None }
                            | Some(alias) =>
                                switch alias->Js.Json.decodeString {
                                    | None => { ...activity_data, alias: None }
                                    | Some(alias) => { ...activity_data, alias: Some(alias) }
                                }
                        }
                        // finds delegate's info
                        let activity_data = switch obj->Js.Dict.get("delegate") {
                            | None => { ...activity_data, delegate: None }
                            | Some(delegate) =>
                                switch delegate->Js.Json.decodeObject {
                                    | None => { ...activity_data, delegate: None }
                                    | Some(dlgt) => {
                                        let delegate_alias = 
                                            switch dlgt->Js.Dict.get("alias") {
                                                | None => ""
                                                | Some(alias) =>
                                                    switch alias->Js.Json.decodeString {
                                                        | None => ""
                                                        | Some(alias) => alias
                                                    }
                                            }
                                        let delegate_address = 
                                            switch dlgt->Js.Dict.get("address") {
                                                | None => ""
                                                | Some(address) => 
                                                    switch address->Js.Json.decodeString {
                                                        | None => ""
                                                        | Some(address) => address
                                                    }
                                            }
                                        let delegate_status = 
                                            switch dlgt->Js.Dict.get("active") {
                                                | None => Unknown_delegate
                                                | Some(active) => 
                                                    switch active->Js.Json.decodeBoolean {
                                                        | None => Unknown_delegate
                                                        | Some(active) => 
                                                            if active {
                                                                Active_delegate
                                                            } else {
                                                                Inactive_delegate
                                                            }
                                                    }
                                            }
                                        { ...activity_data, delegate: Some((delegate_alias, delegate_address, delegate_status)) }
                                    }
                                }
                        }
                        // finds number of token transfers
                        let activity_data = switch obj->Js.Dict.get("tokenTransfersCount") {
                            | None => { ...activity_data, token_transfers_count: None }
                            | Some(transfers) =>
                                switch transfers->Js.Json.decodeNumber {
                                    | None => { ...activity_data, token_transfers_count: None }
                                    | Some(transfers) => 
                                        { ...activity_data, token_transfers_count: Some(transfers->Belt.Int.fromFloat) }
                                }
                        }
                        // finds number of transactions
                        let activity_data = switch obj->Js.Dict.get("numTransactions") {
                            | None => { ...activity_data, transactions_count: None }
                            | Some(txs) =>
                                switch txs->Js.Json.decodeNumber {
                                    | None => { ...activity_data, transactions_count: None }
                                    | Some(txs) => { ...activity_data, transactions_count: Some(txs->Belt.Int.fromFloat) }
                                }
                        }
                        // finds first activity info
                        let activity_data = {
                            let first_activity_level: option<string> = 
                                switch obj->Js.Dict.get("firstActivity") {
                                    | None => None
                                    | Some(first_activity) =>
                                        switch first_activity->Js.Json.decodeNumber {
                                            | None => None
                                            | Some(first_activity) => Some(first_activity->Belt.Float.toString)
                                        }
                                }
                            let first_activity_time: option<string> = 
                                switch obj->Js.Dict.get("firstActivityTime") {
                                    | None => None
                                    | Some(first_activity) =>
                                        switch first_activity->Js.Json.decodeString {
                                            | None => None
                                            | Some(first_activity) => Some(first_activity)
                                        }
                                }
                            switch [first_activity_time, first_activity_level] {
                                | [Some(time), Some(level)] => 
                                    switch level->Belt.Int.fromString {
                                        | None => { ...activity_data, first_activity: None }
                                        | Some(level) => { ...activity_data, first_activity: Some((time, level)) }
                                    }
                                | _ => { ...activity_data, first_activity: None }
                            }
                        }
                        // finds last activity info
                        let activity_data = {
                            let last_activity_level: option<string> = 
                                switch obj->Js.Dict.get("lastActivity") {
                                    | None => None
                                    | Some(last_activity) =>
                                        switch last_activity->Js.Json.decodeNumber {
                                            | None => None
                                            | Some(last_activity) => Some(last_activity->Belt.Float.toString)
                                        }
                                }
                            let last_activity_time: option<string> = 
                                switch obj->Js.Dict.get("lastActivityTime") {
                                    | None => None
                                    | Some(last_activity) =>
                                        switch last_activity->Js.Json.decodeString {
                                            | None => None
                                            | Some(last_activity) => Some(last_activity)
                                        }
                                }
                            switch [last_activity_time, last_activity_level] {
                                | [Some(time), Some(level)] => 
                                    switch level->Belt.Int.fromString {
                                        | None => { ...activity_data, last_activity: None }
                                        | Some(level) => { ...activity_data, last_activity: Some((time, level)) }
                                    }
                                | _ => { ...activity_data, last_activity: None }
                            }
                        }
                        let _ = set_activity(_ => activity_data)
                        resolve()
                    }
                }
            )
            ->ignore
    }

    React.useEffect1(() => {
        let _ = 
            switch state.user_address {
                | None => AppContext.Update_user_balance(Error("No user"))->update_context
                | Some(addr) => fetch_activity(addr)           
            }

        None
    }, [state.user_address])

    switch state.user_address {
        | None => <div>{"You are not connected"->React.string}</div>
        | Some(addr) => 
            <div className="activity-data">
                <div className="activity-data-body">
                    {
                        switch activity.alias {
                            | None => <div>{React.string("Hello " ++ addr)}</div>
                            | Some(alias) => 
                                [
                                    <div>{React.string("Hello " ++ alias)}</div>,
                                    <div>
                                        <div>{"Your address: "->React.string}</div>
                                        <div>{addr->React.string}</div>
                                    </div>
                                ]->React.array
                        }
                    }
                    {
                        switch activity.transactions_count {
                            | None => React.null
                            | Some(txs) =>
                                <div>
                                    <div>{"Number of transactions:"->React.string}</div>
                                    <div>{txs->Belt.Int.toString->React.string}</div>
                                </div>
                        }
                    }
                    {
                        switch activity.delegate {
                            | None => React.null
                            | Some(delegate) =>
                                <div>
                                    {
                                        let (alias, _, status) = delegate
                                        [
                                            <div>{"Delegate:"->React.string}</div>,
                                            <div>
                                                {alias->React.string} 
                                                {
                                                    switch status {
                                                        | Unknown_delegate => 
                                                            <span className="material-icons">
                                                                {"help_outline"->React.string}
                                                            </span>
                                                        | Active_delegate => 
                                                            <span className="material-icons">
                                                                {"account_circle"->React.string}
                                                            </span>
                                                        | Inactive_delegate => 
                                                            <span className="material-icons">
                                                                {"no_accounts"->React.string}
                                                            </span>
                                                    }
                                                }
                                            </div>
                                        ]->React.array
                                    }
                                </div>
                        }
                    }
                    {
                        switch activity.token_transfers_count {
                            | None => React.null
                            | Some(transfers) =>
                                <div>
                                    <div>{"Number of token transfers:"->React.string}</div>
                                    <div>{transfers->Belt.Int.toString->React.string}</div>
                                </div>
                        }
                    }
                    {
                        switch activity.last_activity {
                            | None => React.null
                            | Some(last_activity) => {
                                let (time, level) = last_activity
                                <div>
                                    <div>{"Last activity:"->React.string}</div>
                                    <div>{time->React.string}</div>
                                    <div>{level->Belt.Int.toString->React.string}</div>
                                </div>
                            }
                        }
                    }
                    {
                        switch activity.first_activity {
                            | None => React.null
                            | Some(first_activity) => {
                                let (time, level) = first_activity
                                <div>
                                    <div>{"First activity:"->React.string}</div>
                                    <div>{time->React.string}</div>
                                    <div>{level->Belt.Int.toString->React.string}</div>
                                </div>
                            }
                        }
                    }
                </div>
            </div>
    }
}