/*
 * AppController.j
 * ArrayController
 *
 * Created by __Me__ on __Date__.
 * Copyright 2008 __MyCompanyName__. All rights reserved.
 */

@import <Foundation/CPObject.j>
@import <AppKit/CPArrayController.j>


CPLogRegister(CPLogConsole);

@implementation AppController : CPObject
{
    @outlet CPWindow            theWindow;
    @outlet CPTableView         tableView;
    @outlet CPTextField         totalCountField;
    @outlet CPTextField         selectedNameField;
    @outlet CPTextField         selectedPriceField;

    CPArray                     _itemsArray    @accessors(property=itemsArray);
    @outlet CPArrayController   arrayController;
    
    @outlet CPPanel             itemPanel;
    @outlet CPObjectController  objectController;
            Item                _currentItem    @accessors(property=currentItem);
}

- (void)awakeFromCib
{
    var contentView = [theWindow contentView];
    
    [arrayController setEditable:YES];
    [arrayController setObjectClass:Item];
    [arrayController setAutomaticallyPreparesContent:YES];

    [arrayController setSelectsInsertedObjects:YES];
    [arrayController setAvoidsEmptySelection:YES];

    //create our UI elements

    //[tableView setCenter:[contentView center]];
    [tableView setBackgroundColor:[CPColor whiteColor]];
    [tableView setDelegate:self];

//    var column = [[CPTableColumn alloc] initWithIdentifier:@"name"];
//   [column setEditable:YES];
//    [[column headerView] setStringValue:@"Name"];
//    [tableView addTableColumn:column];

//    column = [[CPTableColumn alloc] initWithIdentifier:@"price"];
//    [column setEditable:YES];
//    [[column headerView] setStringValue:@"Price"];
//    [tableView addTableColumn:column];

//    column = [[CPTableColumn alloc] initWithIdentifier:@"all right"];
//    [[column headerView] setStringValue:@"Righteousness"];
//    [tableView addTableColumn:column];

    //[tableView setDataSource:self];

    //create our bindings

//    [self createBindings];

    //order front window

    [theWindow setFullPlatformWindow:YES];
    [theWindow orderFront:self];
}

-(CPArray) itemsArray {
    if(_itemsArray == nil){
        CPLog.trace(@"Property - itemsArray - alloc");
        _itemsArray = [[CPArray alloc] init];
    }
    return _itemsArray;
}


- (BOOL)tableView:(CPTableView)aTableView shouldEditTableColumn:(CPTableColumn)aTableColumn row:(int)rowIndex
{
    return YES;
}

- (void)createBindings
{
    // bind array controller to self's itemsArray

    [arrayController bind:@"contentArray" toObject:self withKeyPath:@"itemsArray" options:nil];

    // bind the total field -- no options on this one
    [totalCountField bind:CPValueBinding toObject:arrayController
              withKeyPath:@"selectedObjects.@sum.price" options:nil];

    var bindingOptions = @{};
    //[bindingOptions setObject:@"No Name" forKey:@"NSNullPlaceholder"];
    [selectedNameField bind:CPValueBinding toObject:arrayController
                withKeyPath:@"selection.name" options:bindingOptions];

    // binding for "name" column
    var tableColumn = [tableView tableColumnWithIdentifier:@"name"],
        bindingOptions = @{};

    [tableColumn bind:CPValueBinding toObject:arrayController
          withKeyPath:@"arrangedObjects.name" options:bindingOptions];


    // binding options for "price"
    // no need for placeholder as overridden by formatters
    bindingOptions = @{};
    [bindingOptions removeObjectForKey:@"NSNullPlaceholder"];
    [bindingOptions setObject:YES forKey:CPValidatesImmediatelyBindingOption];
    [selectedPriceField bind:CPValueBinding toObject: arrayController
                 withKeyPath:@"selection.price" options:bindingOptions];

    // binding for "price" column
    tableColumn = [tableView tableColumnWithIdentifier:@"price"];
    bindingOptions = [CPDictionary dictionaryWithObject:YES forKey:CPValidatesImmediatelyBindingOption];
    [tableColumn bind:CPValueBinding toObject:arrayController
          withKeyPath:@"arrangedObjects.price" options:bindingOptions];

    // binding for "all right" column
    tableColumn = [tableView tableColumnWithIdentifier:@"all right"];
    bindingOptions = [CPDictionary dictionaryWithObject:[WLWrongToRightTransformer new] forKey:CPValueTransformerBindingOption];
    [tableColumn bind:CPValueBinding toObject:arrayController withKeyPath:@"arrangedObjects.rightOrWrong" options:bindingOptions];
}

/*- (unsigned int)countOfItemsArray
{
    CPLog.trace(@"(unsigned int)countOfItemsArray");
    return [_itemsArray count];
}

- (id)objectInItemsArrayAtIndex:(unsigned int)index
{
    CPLog.trace(@"(id)objectInItemsArrayAtIndex:(unsigned int)index");
    return [_itemsArray objectAtIndex:index];
}

- (void)insertObject:(id)anObject inItemsArrayAtIndex:(unsigned int)index
{
    CPLog.trace(@"(void)insertObject:(id)anObject inItemsArrayAtIndex:(unsigned int)index");
    [_itemsArray insertObject:anObject atIndex:index];
}

- (void)removeObjectFromItemsArrayAtIndex:(unsigned int)index
{
    CPLog.trace(@"(void)removeObjectFromItemsArrayAtIndex:(unsigned int)index");
    [_itemsArray removeObjectAtIndex:index];
}

- (void)replaceObjectInItemsArrayAtIndex:(unsigned int)index withObject:(id)anObject
{
    CPLog.trace(@"(void)replaceObjectInItemsArrayAtIndex:(unsigned int)index withObject:(id)anObject");
    [_itemsArray replaceObjectAtIndex:index withObject:anObject];
}
*/

-(@action) kvcAdd:(id) sender {
    var kvc = [self mutableArrayValueForKey:@"itemsArray"];
    [kvc insertObject:[Item new] atIndex:0];
}

-(@action) kvcEdit:(id) sender {
    var kvc = [self mutableArrayValueForKey:@"itemsArray"];
    var item = [kvc objectAtIndex:0];
    [item setName:@"Edit kvc"];
    [item setPrice:564];
}

-(@action) kvcReplace:(id) sender {
    var kvc = [self mutableArrayValueForKey:@"itemsArray"];
    var item = [Item new];  
    [item setName:@"Tom"];
    [item setPrice:3232];
    [kvc replaceObjectAtIndex:0 withObject:item];
}

-(@action) kvcDelete:(id) sender {
    var kvc = [self mutableArrayValueForKey:@"itemsArray"];
    [kvc removeObjectAtIndex:0];
}

-(@action) kvcValidate:(id) sender {
    var kvc = [self mutableArrayValueForKey:@"itemsArray"];
    var item = [kvc objectAtIndex:0];
    var validateValue = [CPNumber numberWithInt:[item price]];
    var errorValue = [[CPError alloc] init];
//    [item validateValue:validateValue forKey:@"price" error: errorValue];
}

-(@action) showItemPanel:(id) sender {
    var kvc = [self mutableArrayValueForKey:@"itemsArray"];
    var selectedItem = [kvc objectAtIndex:[tableView selectedRow]];
    var item = [[Item alloc] initWithItem:selectedItem];
//    [self setValue:item forKey:@"currentItem"];
    [self setCurrentItem:item];

    CPLog.trace(@"(@action) showItemPanel:(id) sender - %@",_currentItem);

	[itemPanel setTitle:@"Item properties"];
	[itemPanel center];
	[CPApp runModalForWindow:itemPanel];

}

-(@action) itemPanel:(id) sender {
    CPLog.trace(@"@action) itemPanel:(id) sender - title: %@",[sender title]);
    if([[sender title] isEqualToString:@"OK"]){
        CPLog.trace(@"@action) replace index %i with item %@",_currentItem);
        var kvc = [self mutableArrayValueForKey:@"itemsArray"];
        var row = [kvc indexOfObject:_currentItem];
        [kvc replaceObjectAtIndex:row withObject:_currentItem];
    }
    [CPApp abortModal];
    [itemPanel close];
    [tableView reloadData];
    [tableView selectRowIndexes: [CPIndexSet indexSetWithIndex:row ] byExtendingSelection:NO];
}


@end

var ItemIndex = 0;

@implementation Item : CPObject
{
    float    _index          @accessors(property=index);
    float    _price          @accessors(property=price);
    CPString _name           @accessors(property=name);
    CPString _rightOrWrong   @accessors(property=rightOrWrong);
}

- (id)init
{
    self = [super init];
    _index = ItemIndex++;
    _price = 7.0;
    _name = "bob " + (ItemIndex);
    _rightOrWrong = "wrong";
    return self;
}

- (id)initWithItem:(Item) aItem
{
    self = [self init];
    _index =        [aItem index];
    _name =         [aItem name];
    _price =        [aItem price];
    _rightOrWrong = [aItem rightOrWrong];
    return self;
}

-(void) setFromItem:(Item) aItem{
    _index =        [aItem index];
    _name =         [aItem name];
    _price =        [aItem price];
    _rightOrWrong = [aItem rightOrWrong];
}

-(void) setName:(CPString) name {
    CPLog.trace(@"Item - (void) setName:(CPString) name: %@",name);
    _name = [CPString stringWithString:name];
}

-(void) setPrice:(float) price {
    CPLog.trace(@"Item - (void) setPrice:(float) price: %@", price);
    _price = price;
}

-(void) setRightOrWrong:(CPString) rightOrWrong {
    CPLog.trace(@"Item - (void) setRightOrWrong:(CPString) rightOrWrong: %@:", rightOrWrong);
    _rightOrWrong = [CPString stringWithString:rightOrWrong];;
}


- (BOOL)validatePrice:(id)value error:(/*{*/CPError/*}*/)error
{
    CPLog.trace(@"(BOOL)validatePrice:(id)value error:(/*{*/CPError/*}*/)error");
    if ([value intValue] >= 0)
        return YES;

    return NO;
}

-(BOOL) isEqual:(Item) item {
    CPLog.trace(@"Item - (BOOL) isEqual:(Item) item  - self vs item %@,%@",self,item);
    if(_index == [item index]){
        CPLog.trace(@"Item - (BOOL) isEqual:(Item) item TRUE");
        return YES;
    }
    return NO;
    
}

-(CPString) description{
    return [CPString stringWithFormat:@"Item index:name:price  - %i:%@:%f",_index,_name,_price];
}


@end

@implementation WLWrongToRightTransformer : CPValueTransformer
{
}

+ (BOOL)allowsReverseTransformation
{
    CPLog.trace(@"WLWrongToRightTransformer - (BOOL)allowsReverseTransformation");
    return NO;
}

+ (Class)transformedValueClass
{
    CPLog.trace(@"WLWrongToRightTransformer - (BOOL)transformedValueClass");
    return [CPString class];
}

- (id)transformedValue:(id)aValue
{
    CPLog.trace(@"WLWrongToRightTransformer - ((id)transformedValue:(id)aValue");
    return aValue == "wrong" ? "right" : aValue;
}

@end
