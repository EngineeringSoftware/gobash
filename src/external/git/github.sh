#!/bin/bash
#
# https://github.com/EngineeringSoftware/gobash/blob/main/LICENSE
#
# GitHub util functions.

### Functions that fetch data from GitHub should do no other work, but
### only fetch the data.  The user should then store the return value
### into a file that can be further processed, but other (non-fetcher)
### functions.

if [ -n "${GITHUB_MOD:-}" ]; then return 0; fi
readonly GITHUB_MOD=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

. ${GITHUB_MOD}/../../p.sh


# ----------
# Functions.

function github_enabled() {
        # Check if this module is enabled.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 0 ] && { ctx_wn $ctx; return $EC; }
        shift 0 || { ctx_wn $ctx; return $EC; }

        ! is_exe $ctx "curl" && { ctx_w $ctx "no curl"; return $FALSE; }
        ! is_exe $ctx "jq" && { ctx_w $ctx "no jq"; return $FALSE; }

        return $TRUE
}

function github_tags() {
        # Fetch tags (and print in json format).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r user="${1}"
        local -r token="${2}"
        local -r url="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ -z "${user}" ] && { ctx_w $ctx "no user"; return $EC; }
        [ -z "${token}" ] && { ctx_w $ctx "no token"; return $EC; }
        [ -z "${url}" ] && { ctx_w $ctx "no url"; return $EC; }

        curl -u "${user}:${token}" \
             -H "Accept: application/vnd.github.v3+json" \
             "${url}/tags" \
             2>/dev/null
}

function github_prs() {
        # Fetch PRs (and print in json format).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r user="${1}"
        local -r token="${2}"
        local -r url="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ -z "${user}" ] && { ctx_w $ctx "no user"; return $EC; }
        [ -z "${token}" ] && { ctx_w $ctx "no token"; return $EC; }
        [ -z "${url}" ] && { ctx_w $ctx "no url"; return $EC; }

        curl -u "${user}:${token}" \
             -H "Accept: application/vnd.github.v3+json" \
             "${url}/pulls?state=open&per_page=100" \
             2>/dev/null
}

function github_branches() {
        # Fetch branches (and print in json format).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 3 ] && { ctx_wn $ctx; return $EC; }
        local -r user="${1}"
        local -r token="${2}"
        local -r url="${3}"
        shift 3 || { ctx_wn $ctx; return $EC; }

        [ -z "${user}" ] && { ctx_w $ctx "no user"; return $EC; }
        [ -z "${token}" ] && { ctx_w $ctx "no token"; return $EC; }
        [ -z "${url}" ] && { ctx_w $ctx "no url"; return $EC; }

        curl -u "${user}:${token}" \
             -H "Accept: application/vnd.github.v3+json" \
             "${url}/branches?per_page=100" \
             2> /dev/null
}

function github_pr_commits() {
        # Fetch commits for the given PR (and print in json format).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 4 ] && { ctx_wn $ctx; return $EC; }
        local -r user="${1}"
        local -r token="${2}"
        local -r url="${3}"
        local -r number="${4}"
        shift 4 || { ctx_wn $ctx; return $EC; }

        [ -z "${user}" ] && { ctx_w $ctx "no user"; return $EC; }
        [ -z "${token}" ] && { ctx_w $ctx "no token"; return $EC; }
        [ -z "${url}" ] && { ctx_w $ctx "no url"; return $EC; }
        [ -z "${number}" ] && { ctx_w $ctx "no number"; return $EC; }

        curl -u "${user}:${token}" \
             -H "Accept: application/vnd.github.v3+json" \
             "${url}/pulls/${number}/commits" \
             2> /dev/null
}

function github_tag_latest() {
        # Extract latest tag.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r f="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${f}" ] && { ctx_w $ctx "no f"; return $EC; }

        jq -r '.[0] | .name' "${f}"
}

function github_branch_info() {
        # Fetch branch info (and print in json format).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 4 ] && { ctx_wn $ctx; return $EC; }
        local -r user="${1}"
        local -r token="${2}"
        local -r url="${3}"
        local -r branch="${4}"
        shift 4 || { ctx_wn $ctx; return $EC; }

        [ -z "${user}" ] && { ctx_w $ctx "no user"; return $EC; }
        [ -z "${token}" ] && { ctx_w $ctx "no token"; return $EC; }
        [ -z "${url}" ] && { ctx_w $ctx "no url"; return $EC; }
        [ -z "${branch}" ] && { ctx_w $ctx "no branch"; return $EC; }

        curl -u "${user}:${token}" \
             -H "Accept: application/vnd.github.v3+json" \
             "${url}/branches/${branch}" \
             2>/dev/null
}

function github_branch_latest_sha() {
        # Extract latest sha from branch info.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 1 ] && { ctx_wn $ctx; return $EC; }
        local -r f="${1}"
        shift 1 || { ctx_wn $ctx; return $EC; }

        [ -z "${f}" ] && { ctx_w $ctx "no f"; return $EC; }

        jq -r '.commit | .sha' "${f}"
}

function github_runs() {
        # Fetch action runs (and print in json format).
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 4 ] && { ctx_wn $ctx; return $EC; }
        local -r user="${1}"
        local -r token="${2}"
        local -r url="${3}"
        local -r branch="${4}"
        shift 4 || { ctx_wn $ctx; return $EC; }

        [ -z "${user}" ] && { ctx_w $ctx "no user"; return $EC; }
        [ -z "${token}" ] && { ctx_w $ctx "no token"; return $EC; }
        [ -z "${url}" ] && { ctx_w $ctx "no url"; return $EC; }
        [ -z "${branch}" ] && { ctx_w $ctx "no branch"; return $EC; }

        # Select only those that completed on the given branch.
        curl -u "${user}:${token}" \
             -H "Accept: application/vnd.github.v3+json" \
             "${url}/actions/runs?branch=${branch}&status=completed&per_page=100&event=push" \
             2>/dev/null
}

function github_jobs() {
        # Fetch jobs for the given RUN-ID.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 4 ] && { ctx_wn $ctx; return $EC; }
        local -r user="${1}"
        local -r token="${2}"
        local -r url="${3}"
        local -r id="${4}"
        shift 4 || { ctx_wn $ctx; return $EC; }

        [ -z "${user}" ] && { ctx_w $ctx "no user"; return $EC; }
        [ -z "${token}" ] && { ctx_w $ctx "no token"; return $EC; }
        [ -z "${url}" ] && { ctx_w $ctx "no url"; return $EC; }
        [ -z "${id}" ] && { ctx_w $ctx "no id"; return $EC; }

        curl -u "${user}:${token}" \
             -H "Accept: application/vnd.github.v3+json" \
             "${url}/actions/runs/${id}/jobs" \
             2>/dev/null
}

function github_id_to_sha() {
        # Extract SHA for the given run id.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 2 ] && { ctx_wn $ctx; return $EC; }
        local -r runsf="${1}"
        local -r id="${2}"
        shift 2 || { ctx_wn $ctx; return $EC; }

        [ -z "${runsf}" ] && { ctx_w $ctx "no runs"; return $EC; }
        [ -z "${id}" ] && { ctx_w $ctx "no id"; return $EC; }

        jq -r '.workflow_runs | .[] | select(.id=='"${id}"') | .head_sha' "${runsf}"
}

function github_is_outcome() {
        # Return if the action name resulted in the given outcome.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 4 ] && { ctx_wn $ctx; return $EC; }
        local -r jobsf="${1}"
        local -r action="${2}"
        local -r step="${3}"
        local -r outcome="${4}"
        shift 4 || { ctx_wn $ctx; return $EC; }

        [ -z "${jobsf}" ] && { ctx_w $ctx "no jobs"; return $EC; }
        [ -z "${action}" ] && { ctx_w $ctx "no action"; return $EC; }
        [ -z "${step}" ] && { ctx_w $ctx "no step"; return $EC; }
        [ -z "${outcome}" ] && { ctx_w $ctx "no outcome"; return $EC; }

        local entry
        entry=$(jq '.jobs | .[] | select(.name=="'"${action}"'") | .steps[] | select(.name=="'"${step}"'") | select(.conclusion=="'"${outcome}"'")' "${jobsf}") || \
                { ctx_w $ctx "jq error"; return $EC; }

        [[ $($X_WC -w <<< ${entry}) -gt 0 ]]
}

function github_create_pr() {
        # https://stackoverflow.com/questions/56027634/creating-a-pull-request-using-the-api-of-github
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 7 ] && { ctx_wn $ctx; return $EC; }
        local -r user="${1}"
        local -r token="${2}"
        local -r url="${3}"
        local -r branch="${4}"
        local -r base="${5}"
        local -r title="${6}"
        local -r body="${7}"
        shift 7 || { ctx_wn $ctx; return $EC; }

        [ -z "${url}" ] && { ctx_w $ctx "no url"; return $EC; }
        [ -z "${user}" ] && { ctx_w $ctx "no user"; return $EC; }
        [ -z "${token}" ] && { ctx_w $ctx "no token"; return $EC; }
        [ -z "${branch}" ] && { ctx_w $ctx "no branch"; return $EC; }
        [ -z "${base}" ] && { ctx_w $ctx "no base"; return $EC; }
        [ -z "${title}" ] && { ctx_w $ctx "no title"; return $EC; }
        [ -z "${body}" ] && { ctx_w $ctx "no body"; return $EC; }

        curl -u "${user}:${token}" \
             -H "Accept: application/vnd.github.v3+json" \
             -X POST \
             -d '{ "title": "'"${title}"'", "body": "'"${body}"'", "head": "'"${branch}"'", "base": "'"${base}"'" }' \
             "${url}/pulls" \
             2>/dev/null
}

function github_pr_add_comment() {
        # Add a comment to a PR.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 5 ] && { ctx_wn $ctx; return $EC; }
        local -r user="${1}"
        local -r token="${2}"
        local -r url="${3}"
        local -r pr="${4}"
        local -r comment="${5}"
        shift 5 || { ctx_wn $ctx; return $EC; }

        [ -z "${user}" ] && { ctx_w $ctx "no user"; return $EC; }
        [ -z "${token}" ] && { ctx_w $ctx "no token"; return $EC; }
        [ -z "${url}" ] && { ctx_w $ctx "no url"; return $EC; }
        [ -z "${pr}" ] && { ctx_w $ctx "no pr"; return $EC; }
        [ -z "${comment}" ] && { ctx_w $ctx "no comment"; return $EC; }

        curl -u "${user}:${token}" \
             -L \
             -X POST \
             -H "Accept: application/vnd.github+json" \
             "${url}/issues/${pr}/comments" \
             -d '{"body": "'"${comment}"'"}' \
             2>/dev/null
}

function github_pr_assign_reviewer() {
        # Assign a reviewer to a PR.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 5 ] && { ctx_wn $ctx; return $EC; }
        local -r user="${1}"
        local -r token="${2}"
        local -r url="${3}"
        local -r pr="${4}"
        local -r reviewer="${5}"
        shift 5 || { ctx_wn $ctx; return $EC; }

        [ -z "${user}" ] && { ctx_w $ctx "no user"; return $EC; }
        [ -z "${token}" ] && { ctx_w $ctx "no token"; return $EC; }
        [ -z "${url}" ] && { ctx_w $ctx "no url"; return $EC; }
        [ -z "${pr}" ] && { ctx_w $ctx "no pr"; return $EC; }
        [ -z "${reviewer}" ] && { ctx_w $ctx "no reviewer"; return $EC; }

        curl -u "${user}:${token}" \
             -X POST \
             "${url}/pulls/${pr}/requested_reviewers" \
             -d '{ "reviewers": ["'"${reviewer}"'"] }' \
             2>/dev/null
}

function github_commit_info() {
        # Return commit info for the given SHA.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 4 ] && { ctx_wn $ctx; return $EC; }
        local -r user="${1}"
        local -r token="${2}"
        local -r url="${3}"
        local -r short_sha="${4}"
        shift 4 || { ctx_wn $ctx; return $EC; }

        [ -z "${user}" ] && { ctx_w $ctx "no user"; return $EC; }
        [ -z "${token}" ] && { ctx_w $ctx "no token"; return $EC; }
        [ -z "${url}" ] && { ctx_w $ctx "no url"; return $EC; }
        [ -z "${short_sha}" ] && { ctx_w $ctx "no sha"; return $EC; }

        curl -u "${user}:${token}" \
             -H "Accept: application/vnd.github.v3+json" \
             "${url}/commits/${short_sha}" \
             2>/dev/null
}

function github_commits() {
        # Fetch commits from the given SHA.
        local ctx; is_ctx "${1}" && ctx="${1}" && shift
        [ $# -ne 4 ] && { ctx_wn $ctx; return $EC; }
        local -r user="${1}"
        local -r token="${2}"
        local -r url="${3}"
        local -r sha="${4}"
        shift 4 || { ctx_wn $ctx; return $EC; }

        [ -z "${user}" ] && { ctx_w $ctx "no user"; return $EC; }
        [ -z "${token}" ] && { ctx_w $ctx "no token"; return $EC; }
        [ -z "${url}" ] && { ctx_w $ctx "no url"; return $EC; }
        [ -z "${sha}" ] && { ctx_w $ctx "no sha"; return $EC; }

        curl -u "${user}:${token}" \
             -H "Accept: application/vnd.github.v3+json" \
             "${url}/commits?per_page=100&sha=${sha}" \
             2>/dev/null
}
