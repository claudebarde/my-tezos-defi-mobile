let format_token_amount = (amount: float): result<float, string> => {
    switch amount->Js.Float.toFixedWithPrecision(~digits=5)->Belt.Float.fromString {
        | None => Error("N/A")
        | Some(num) => Ok(num /. 1.0)
    }
}