# CHANGELOG

##### Changelog v2.0.1 12/03/2017:

- Add `upload-file.json` file.

- Resource `remote_file 'C:\\chef\\upload-file.json'` changed to `cookbook_file 'C:\chef\upload-file.json'` in `requirements.rb` recipe.

##### Changelog v2.0.0 08/02/2017:

- Improve code of recipes and helpers according to Ruby Style Guide.

- Some methods changed their name.

- New global variable `$node_name` was added in `default.rb` recipe.

- Delete and replace some varibles to improve the cookbook's workflow.

##### Changelog v1.2.4 30/01/2017:

- New attributes `default["war"]["url_bbi"]` and `default["war"]["url_panama"]` was added to manage source of `Eva.war` file.

- Now Panama's servers can download `Eva.war` file.

##### Changelog v1.2.3 05/12/2016:

- Due to SQL Server isn't installed in POS `ruby_block 'Verify PowerShell'` resource verifies PowerShell version.

##### Changelog v1.2.2 02/12/2016:

- Now, `ruby_block 'Verify PowerShell'` resource of `requirements.rb` recipe verifies if SQL Server module exists.

##### Changelog v1.2.1 16/11/2016:

- Now, recipe `download_img.rb` was used in nodes type POS.

- A condition in `default.rb` recipe was added to avoid using `download_img.rb` recipe on BBI POS.

##### Changelog v1.2.0 10/11/2016:

- New `download_pdt.rb` recipe has the code to download the files needed to update the pdt.

- Recipe `download_pdt.rb` was included in `default.rb` and located into `if` statement to only be executed by nodes type server.

- A condition in `default.rb` recipe was added to avoid using the new recipe on BBI servers.

- New attributes `default["pdt"]["app"]`, `default["pdt"]["db"]` and `default["pdt"]["readme"]`.

- A condition in `download_proc.rb` recipe was added to avoid downloading Eva.war in nodes of Panamá.

##### Changelog v1.1.0 01/11/2016:

- New `download_img.rb` recipe has the code to download the images to POS (flytech).

- New `mercadoni.rb` recipe has the code to update the keyboard of POS to identify client mercadoni.

- Recipes `download_img.rb` and `mercadoni.rb` was included in `default.rb` recipe but these aren't in operation yet.

- A condition in `default.rb` recipe was added to avoid using the two news recipes in server nodes.

- The definition of `unicentro` variable changed in `download_proc.rb` recipe.

- The method `isCurrentVersion` of `Eva` module write the current version in the log.

- The name of `ruby_block 'Send Email'` resource changed to `'Send Email war'` in `download_proc.rb` recipe to avoid it will be overwrite.

- New attributes `default["mercadoni"]["url"]`, `default["mercadoni"]["file"]`, `default["mercadoni"]["delimiter"]` and `default["advertising"]["url"]`.

- Resources related with `json` gem were deleted in `requirements.rb` recipe, these aren't necessary.

##### Changelog v1.0.1 18/10/2016:

- A condition in `download_proc.rb` recipe was added to avoid downloading Eva.war in the shop Unicentro.

- A condition in `default.rb` recipe was added to avoid downloading Eva.war in POS nodes.

##### Changelog v1.0.0 12/10/2016:

- Now, the cookbook is modular. Separate the download process and the verification of requirements.

- New `download_proc.rb` recipe has the code to download the war.

- New `requirements.rb` recipe has the code to verify the requirements to deployment.

- Recipes `download_proc.rb` and `requirements.rb` was included in `default.rb` recipe.
