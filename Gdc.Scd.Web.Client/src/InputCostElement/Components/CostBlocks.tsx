import * as React from 'react';
import { Container, ComboBoxField, Panel, FormPanel, RadioField, ContainerField, Grid, Column, Toolbar, Button, Label, Dialog } from '@extjs/ext-react';
import { CostBlockInputState, EditItem, CheckItem } from '../States/CostBlock'
import { NamedId } from '../../Common/States/NamedId';
import { SelectList, MultiSelectList } from '../../Common/States/SelectList';
import { Filter } from './Filter';

Ext.require('Ext.grid.plugin.CellEditing');
Ext.require('Ext.MessageBox');

export interface CostBlockActions {
  onCountrySelected?: (countryId: string) => void
  onCostElementSelected?: (costElementId: string) => void
  onCostElementFilterSelectionChanged?: (
    costElementId: string, 
    filterItemId: string,
    isSelected: boolean) => void
  onCostElementFilterReseted?: (costElementId: string) => void
  onInputLevelSelected?: (inputLevelId: string) => void
  onInputLevelFilterSelectionChanged?: (
    inputLevelId: string, 
    filterItemId: string,
    isSelected: boolean) => void
  onInputLevelFilterReseted?: (inputLevelId: string) => void
  onEditItemsCleared?: () => void
  onItemEdited?: (item: EditItem) => void
  onEditItemsSaving?: () => void
}

export interface SelectListFilter {
  selectList: SelectList<NamedId>
  filter: CheckItem[],
  filterName: string,
  isVisibleFilter: boolean
}

export interface CostBlockProps {
  country: SelectList<NamedId>,
  costElement: SelectListFilter & {
    description: string
  }
  inputLevel: SelectListFilter
  edit: {
    nameColumnTitle: string
    valueColumnTitle: string
    items: EditItem[]
    isVisible: boolean,
    isEnableSave: boolean,
    isEnableClear: boolean
  }
}

export class CostBlock extends React.Component<CostBlockProps & CostBlockActions> {
  public render() {
    const { 
      country, 
      costElement, 
      inputLevel,
      onCostElementSelected,
      onInputLevelSelected,
      onCostElementFilterSelectionChanged,
      onInputLevelFilterSelectionChanged,
      onCostElementFilterReseted,
      onInputLevelFilterReseted,
      edit
    } = this.props;

    return (
      <Container layout={{ type: 'hbox', align: 'stretch '}}>
        <Container flex={1} layout="vbox" shadow>
          <Container layout="hbox">
            <FormPanel flex={1}>
              {this.countryCombobox(country)}
              {
                this.radioFieldSet(
                  'costelements', 
                  costElement.selectList, 
                  'Cost Elements', 
                  costElement => onCostElementSelected && onCostElementSelected(costElement.id)
                )
              }
            </FormPanel>

            { 
              costElement.isVisibleFilter &&
              <Filter 
                title="Dependent from:" 
                valueColumnText={costElement.filterName}
                items={costElement.filter} 
                height="500"
                flex={1}
                onSelectionChanged={
                  (item: NamedId, isSelected: boolean) =>
                    onCostElementFilterSelectionChanged &&
                    onCostElementFilterSelectionChanged(
                      costElement.selectList.selectedItemId,
                      item.id,
                      isSelected
                    )
                }
                onReset={
                  () => 
                    onCostElementFilterReseted && 
                    onCostElementFilterReseted(costElement.selectList.selectedItemId)
                }
              />
            }
          </Container>

          <Panel title="Description" padding="10">
            {
              costElement.description != null &&
              <Label html={costElement.description}/>
            }
          </Panel>
        </Container>

        <Container flex={1} layout="vbox" padding="0px 0px 0px 5px">
          <Container layout="hbox">
            <FormPanel flex={1}>
              {
                this.radioFieldSet(
                  'inputlevels', 
                  inputLevel.selectList, 
                  'Input Level',
                  inputLevel => onInputLevelSelected && onInputLevelSelected(inputLevel.id)
                )
              }
            </FormPanel>
            
            {
              inputLevel.isVisibleFilter &&
              <Filter 
                valueColumnText={inputLevel.filterName}
                items={inputLevel.filter} 
                height="350"
                flex={1}
                onSelectionChanged={
                  (item: NamedId, isSelected: boolean) =>
                    onInputLevelFilterSelectionChanged &&
                    onInputLevelFilterSelectionChanged(
                      inputLevel.selectList.selectedItemId,
                      item.id,
                      isSelected
                    )
                }
                onReset={() => onInputLevelFilterReseted && onInputLevelFilterReseted(inputLevel.selectList.selectedItemId)}
              />
            }
          </Container>

          {
            edit.isVisible && 
            this.editGrid(edit.items, edit.nameColumnTitle, edit.valueColumnTitle)
          }
        </Container>
      </Container>
    );
  }

  private countryCombobox(country: SelectList<NamedId>) {
    const countryStore = Ext.create('Ext.data.Store', {
        data: country.list
    });

    const selectedCountry = 
        countryStore.getData()
                    .findBy(item => (item.data as NamedId).id === country.selectedItemId);

    return (
        <ComboBoxField 
            label="Select a Country:"
            //width="50%"
            displayField="name"
            valueField="id"
            queryMode="local"
            store={countryStore}
            selection={selectedCountry}
            onChange={(combobox, newValue, oldValue) => this.props.onCountrySelected(newValue)}
        />
    );
  }

  private radioField(
    name: string, 
    item: NamedId, 
    selectedCostElementId: string,
    onSelected: (item: NamedId) => void
  ) {
    return (
      <RadioField 
          key={item.id} 
          boxLabel={item.name} 
          name={name} 
          checked={item.id === selectedCostElementId}
          onCheck={radioField => onSelected(item)}
      />
    );
  }

  private radioFieldSet(
    setName: string, 
    selectList: SelectList<NamedId>, 
    label: string, 
    onSelected: (item: NamedId) => void
  ) {    
    return (
      <ContainerField label={label} layout={{type: 'vbox', align: 'left'}}>
        {
          selectList && 
          selectList.list.map(item => 
            this.radioField(
              setName, 
              item, 
              selectList.selectedItemId,
              onSelected
            )
          )
        }
      </ContainerField>
    );
  }

  private editGrid(items: EditItem[], nameTitle: string, valueTitle) {
    const { onItemEdited, edit } = this.props;
    const { isEnableClear, isEnableSave } = edit;

    const store = Ext.create('Ext.data.Store', {
        data: items && items.slice(),
        listeners: {
          update: onItemEdited && 
                  ((store, record, operation, modifiedFieldNames, details) => {
                    if (modifiedFieldNames[0] === 'name') {
                      record.reject();
                    } else {
                      onItemEdited(record.data)
                    }
                  })
        }
    });

    return (
      <Grid 
        store={store} 
        flex={1} 
        shadow 
        height={400}
        columnLines={true}
        // plugins={[
        //   { type: 'cellediting', triggerEvent: 'singletap' },
        //   'selectionreplicator'
        // ]}
        plugins={['cellediting', 'selectionreplicator']}
        selectable={{
          rows: true,
          cells: true,
          columns: true,
          drag: true,
          extensible: 'y'
        }}
        
      >
        <Column text={nameTitle} dataIndex="name" flex={1} extensible={false} />
        <Column text={valueTitle} dataIndex="value" flex={1} editable={true}/>

        <Toolbar docked="bottom">
            <Button 
              text="Clear" 
              flex={1} 
              disabled={!isEnableClear}
              handler={() => this.showClearDialog()}
            />
            <Button 
              text="Save" 
              flex={1} 
              disabled={!isEnableSave}
              handler={() => this.showSaveDialog()}
            />
        </Toolbar>
      </Grid>
    );
  }   

  private showSaveDialog() {
    const { onEditItemsSaving } = this.props;

    Ext.Msg.confirm(
      'Saving changes', 
      'Do you want to save the changes?',
      (buttonId: string) => onEditItemsSaving && onEditItemsSaving()
    );
  }

  private showClearDialog() {
    const { onEditItemsCleared } = this.props;

    Ext.Msg.confirm(
      'Clearing changes', 
      'Do you want to clear the changes??',
      (buttonId: string) => onEditItemsCleared && onEditItemsCleared()
    );
  }

  // private saveDialog() {
  //   return (
  //     <Dialog
  //       title="Saving changes"
  //       bodyPadding="20"
  //       closable
  //       defaultFocus="#ok"
  //     >
  //       Do you want save changes?
  //       <Button itemId="ok" text="Ok"/>
  //       <Button text="Cancel"/>
  //     </Dialog>
  //   );
  // }
}
