
module Shipit
  module Api
    class RollbacksController < BaseController
      require_permission :deploy, :stack

      params do
        requires :sha, String, length: { in: 6..40 }
        accepts :force, Boolean, default: false
        accepts :env, Hash, default: {}
      end
      def create
        commit = stack.commits.by_sha(params.sha) || param_error!(:sha, 'Unknown revision')
        param_error!(:force, "Can't rollback a locked stack") if !params.force && stack.locked?
        deploy = stack.deploys.find_by(until_commit: commit) || param_error!(:sha, 'Cant find associated deploy')
        deploy_env = stack.filter_deploy_envs(params.env)

        rollback = deploy.trigger_rollback(current_user, env: deploy_env, force: params.force)

        render_resource(rollback, status: :accepted)
      end
    end
  end
end
