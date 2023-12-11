# Overview of Question Rendering

The directories and files `app/views/question/` are for simplified rendering.

For each subclass of the `Question` model there will likely be one subdirectory of `app/views/question/`. 

For example we have the `Question::Traditional` model, a subclass of `Question`.  There is an XML partial in `app/views/question/traditionals/_traditional.xml.erb`.  This conforms to [Rails's Rendering Collections](https://guides.rubyonrails.org/layouts_and_rendering.html#rendering-collections).

That is to say the default view directory for `Question` is `app/views/questions/`.  And the default view directory for `Question::Traditional` is `app/views/question/traditionals/`.  Note that in both cases the last directory is "pluralized" (e.g. `/questions/` and `/traditionals`).

With the above convention we can render a heterogenious collection of Questions.  See `app/views/search/index.xml.erb` for an example.
