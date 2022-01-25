@react.component
let make = (~user_address: string) => {
    <div>{React.string("Hello " ++ user_address)}</div>
}