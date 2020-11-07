# add-simple-link-note

## AddSimpleLinkNote

OTRS Module intended to be run with GenericAgent

## Installation

Make sure target directory exists:

`mkdir -p $HOME/Custom/Kernel/System/GenericAgent`

Then copy `AddSimpleLinkNote.pm` to `Custom/Kernel/System/GenericAgent`

## Configuration

Execute Custom Module: `Custom::Kernel::System::GenericAgent::AddSimpleLinkNote`

Mandatory Param Keys:

* `Subject`
* `Body`

Optional Param Keys:

* `Link`
* `SenderType` (Default: system)
* `From` (Default: System <root@localhost>)


For `Subject`, `Body` and `Link` limited HTML escaping is performed (e.g. to avoid JS 
injection) but most normal HTML tags can be used:

* \<em>\</em> for italic
* \<strong>\</strong> for bold
* \<h2><\h2> for headlines

Please Note: The `body` is wrapped in a `<p>`...`</p>` section. So use an extra `</p>` 
at the start and `<p>` at the end if you include your own tags like `h1-5`, `p` or 
`div` in the `body`. 


## Screenshots

![GenericAgentView](img/GenericAgentView.png)

![ArticleView](img/ArticleView.png)

![NoteView](img/NoteView.png)