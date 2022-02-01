@react.component
let make = () => {
    <div>
        <div className="page-title">{React.string("Farms")}</div>
        <div style={ReactDOMStyle.make(~textAlign="center", ())}>
            {"Coming soon"->React.string}
        </div>
    </div>
}