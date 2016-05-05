class ProjectImportWorker
  include Sidekiq::Worker

  # TODO: enabled retry - disabled for QA purposes
  sidekiq_options queue: :gitlab_shell, retry: false

  def perform(current_user_id, tmp_file, namespace_id, path)
    current_user = User.find(current_user_id)

    project = Gitlab::ImportExport::ImportService.execute(archive_file: tmp_file,
                                                          owner: current_user,
                                                          namespace_id: namespace_id,
                                                          project_path: path)
    if project
      project.repository.after_import
      project.import_finish
    else
      logger.error("There was an error during the import: #{tmpfile}")
    end
  end

  def logger
    Sidekiq.logger
  end
end
