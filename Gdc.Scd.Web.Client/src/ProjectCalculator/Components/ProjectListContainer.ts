import { connect } from "react-redux";
import { CommonState } from "../../Layout/States/AppStates";
import { ProjectListProps, ProjectListActions, ProjectList } from "./ProjectList";
import { Urls, deleteProject } from "../Services/ProjectService";
import { selectProject } from "../Actions/ProjectCalculatorActions";
import { loadProjectItemEditData } from "../Actions/ProjectCalculatorAsyncActions";
import { buildComponentUrl } from "../../Common/Services/Ajax";
import { Paths } from "../../Layout/Components/LayoutContainer";
import { Project } from "../States/Project";
import { handleRequest } from "../../Common/Helpers/RequestHelper";

const goToEdit = (history, project: Project) => {
    history.push(buildComponentUrl(`${Paths.projectCalculatorEdit}/${project.id}`));
}

export const ProjectListContainer = connect<ProjectListProps, ProjectListActions, any, CommonState>(
    ({ pages: { projectCalculator } }) => ({
        url: Urls.getBy,
        selectedProject: projectCalculator.selectedProject
    }),
    (dispatch, { history }) => ({
        onInit: () => dispatch(loadProjectItemEditData()),
        onSelectProject: selectedProject => {
            dispatch(selectProject(selectedProject));
        },
        onAdd: () => {
            const newProject: Project = { 
                id: 0, 
                name: null,
                user: null,
                projectItems: []
            };

            dispatch(selectProject(newProject));

            goToEdit(history, newProject);
        },
        onEdit: (store, selectedProject) => {
            goToEdit(history, selectedProject);
        },
        onDelete: (store, selectedProject) => {
            Ext.Msg.confirm(
                'Delete Project', 
                'Do you want to delete the project?',
                (buttonId: string) => {
                    if (buttonId == 'yes') {
                        handleRequest(
                            deleteProject(selectedProject.id).then(() => {
                                const record = store.getById(selectedProject.id);
    
                                store.remove(record);
                            })
                        );
                    }
                }
            );
        },
        onReportClick: (reportName, project) => {
            history.push(buildComponentUrl(`${Paths.projectCalculatorReport}/${reportName}/${project.id}`));
        }
    })
)(ProjectList)