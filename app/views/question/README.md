# Overview of Question Rendering

The directories and files `app/views/question/` are for simplified rendering.

For each subclass of the `Question` model there will likely be one subdirectory of `app/views/question/`. 

For example we have the `Question::Traditional` model, a subclass of `Question`.  There is an XML partial in `app/views/question/traditionals/_traditional.xml.erb`.  This conforms to [Rails's Rendering Collections](https://guides.rubyonrails.org/layouts_and_rendering.html#rendering-collections).

That is to say the default view directory for `Question` is `app/views/questions/`.  And the default view directory for `Question::Traditional` is `app/views/question/traditionals/`.  Note that in both cases the last directory is "pluralized" (e.g. `/questions/` and `/traditionals`).

With the above convention we can render a heterogenious collection of Questions.  See `app/views/search/index.xml.erb` for an example.

## On XML

The following information is what we've gleaned:

- The `qtimemetadatafield` with `fieldlabel` child-node of "question_type" must have a `fieldentry` child-node that conforms to a controlled vocabulary.
  - As of <2023-12-11 Mon> I do not have that controlled vocabulary.
- **Uniqueness considerations** for properties; these *might need to be unique throughout an export*:
  - `item` node's `ident` property
   - It is possible that this must be more generally unique, but I (Jeremy) don't think so.  We have what should be a univerally unique-ish identifier  and prefix via `Question#item_ident` method.
  - `item presentation response_lid` node's `ident` property
  - `item presentation response_lid render_choice response_label` node's `ident`
